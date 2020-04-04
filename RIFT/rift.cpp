#include "rift.h"

namespace cv {

RIFT::RIFT(int nscale, int norient, int nblock, int patchSize, Ptr<FeatureDetector> detector)
{
	m_nscale = nscale;
	m_norient = norient;
	m_nblock = nblock;
	m_patchSize = patchSize;
	m_detector = detector;
}

Ptr<RIFT> RIFT::create(int nscale, int norient, int nblock, int patchSize, Ptr<FeatureDetector> detector)
{
	return Ptr<RIFT>(new RIFT(nscale, norient, nblock, patchSize, detector));
}

void RIFT::calcPhaseCongruency(const Mat& img, Mat& maxMoment, Mat& minMoment, vector<Mat>& Ao)
{
	PhaseCongruency phasecongruency = PhaseCongruency(m_imageSize, m_nscale, m_norient);
	vector<Mat> pc;
	phasecongruency.calc(img, pc, Ao);
	phasecongruency.feature(pc, maxMoment, minMoment);
}

void RIFT::detect(const Mat& img, vector<KeyPoint>& keypoints)
{
	Mat _img;
	if (img.channels() == 3)
		cvtColor(img, _img, COLOR_BGR2GRAY);
	else
		img.copyTo(_img);
	m_imageSize = _img.size();

	// Compute Phase Congruency
	calcPhaseCongruency(_img, m_maxMoment, m_minMoment, m_Ao);

	// Extracte FAST features from Maximum moment
	m_detector->detect(m_maxMoment, keypoints);
}

void RIFT::compute(vector<KeyPoint>& keypoints, Mat& descriptors)
{
	/* Compute maximum index map(MIM) */
	vector<double> vec(m_norient);
	Mat mim(m_imageSize, CV_8UC1);
	for (int i = 0; i < m_imageSize.height; i++)
	{
		for (int j = 0; j < m_imageSize.width; j++)
		{
			for (int k = 0; k < m_norient; k++)
			{
				vec[k] = m_Ao[k].at<double>(i, j);
			}
			int index[2];
			minMaxIdx(vec, 0, 0, 0, index);
			mim.at<uchar>(i, j) = uchar(index[1]);
		}
	}

	/* Compute descriptors */
	vector<KeyPoint> _keypoints = keypoints;
	keypoints.clear();
	descriptors.release();
	const int dim = m_nblock * m_nblock * m_norient;
	int num_kpt = _keypoints.size();
	for (int k = 0; k < num_kpt; k++)
	{
		int x = cvRound(_keypoints[k].pt.x);
		int y = cvRound(_keypoints[k].pt.y);
		int halfpatchSize = m_patchSize / 2;
		int x1 = x - halfpatchSize;
		int y1 = y - halfpatchSize;
		int x2 = x + halfpatchSize + 1;
		int y2 = y + halfpatchSize + 1;
		if (x1 < 0 || y1 < 0 || x2 > m_imageSize.width || y2 > m_imageSize.height)
			continue;
		Mat patch = mim(Range(y1, y2), Range(x1, x2));
		vector<uchar> descriptor(dim, 0);
		double blockSize = double(m_patchSize) / m_nblock;
		for (int i = 0; i < m_nblock; i++)
		{
			for (int j = 0; j < m_nblock; j++)
			{
				Mat block = patch(Range(cvRound(i * blockSize), cvRound((i + 1) * blockSize)), 
					Range(cvRound(j * blockSize), cvRound((j + 1) * blockSize)));
				Size blockSize = block.size();
				int idx_offset = ((i * m_nblock) + j) * m_norient;
				for (int m = 0; m < blockSize.height; m++)
				{
					for (int n = 0; n < blockSize.width; n++)
					{
						int idx = (int)block.at<uchar>(m ,n);
						descriptor[idx_offset + idx]++;
					}
				}
			}
		}
		keypoints.push_back(_keypoints[k]);
		descriptors.push_back(Mat(descriptor).t());
	}
}

void RIFT::detectAndCompute(const Mat& img, vector<KeyPoint>& keypoints, Mat& descriptors)
{
	detect(img, keypoints);
	compute(keypoints, descriptors);
}

void RIFT::detectAndCompute(const Mat& img, const Mat& mask, vector<KeyPoint>& keypoints, Mat& descriptors)
{
	detectAndCompute(img, keypoints, descriptors); // mask is not used
}

void RIFT::getmaxMoment(Mat& dst)
{
	m_maxMoment.copyTo(dst);
}

void RIFT::getminMoment(Mat& dst)
{
	m_minMoment.copyTo(dst);
}

bool findTransform(const vector<KeyPoint>& queryKeypoints, const vector<KeyPoint>& trainKeypoints,
	vector<DMatch>& matches, Mat& homography, float reprojectionThreshold)
{
	const int minNumberMatchesAllowed = 8;

	if (matches.size() < minNumberMatchesAllowed)
		return false;

	// Prepare data for cv::findHomography  
	vector<Point2f> srcPoints(matches.size());
	vector<Point2f> dstPoints(matches.size());
	for (size_t i = 0; i < matches.size(); i++)
	{
		srcPoints[i] = trainKeypoints[matches[i].trainIdx].pt;
		dstPoints[i] = queryKeypoints[matches[i].queryIdx].pt;
	}

	// Find homography matrix and get inliers mask  
	vector<uchar> inliersMask(srcPoints.size());
	homography = findHomography(srcPoints, dstPoints, inliersMask, RANSAC, reprojectionThreshold);

	vector<DMatch> inliers;
	for (size_t i = 0; i < inliersMask.size(); i++)
	{
		if (inliersMask[i])
			inliers.push_back(matches[i]);
	}

	matches.swap(inliers);
	return matches.size() > minNumberMatchesAllowed;
}

}