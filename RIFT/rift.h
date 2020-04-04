#pragma once

#include <opencv2/opencv.hpp>
#include "phasecongruency.h"

using namespace std;

namespace cv {

class RIFT {

private: // private variable
	/* parameters */
	int m_nscale;		// Number of wavelet scales
	int m_norient;		// Number of filter orientations
	int m_nblock;		// Block Number of each row or column when computing descriptors
	int m_patchSize;    // Size of patch when computing descriptors

	Size m_imageSize;
	Ptr<FeatureDetector> m_detector;

	Mat m_maxMoment;	// Maximum moment. This is used as a indicator of edge strength
	Mat m_minMoment;	// Minimum moment. This is used as a indicator of corner strength
	vector<Mat> m_Ao;	

public: // interface function
	RIFT(int nscale=4, int norient=6, int nblock=6, int patchSize = 96, Ptr<FeatureDetector> detector = FastFeatureDetector::create());
	static Ptr<RIFT> create(int nscale = 4, int norient = 6, int nblock = 6, int patchSize = 96, Ptr<FeatureDetector> detector = FastFeatureDetector::create());

	void detect(const Mat& img, vector<KeyPoint>& keypoints);
	void compute(vector<KeyPoint>& keypoints, Mat& descriptors);
	void detectAndCompute(const Mat& img, vector<KeyPoint>& keypoints, Mat& descriptors);
	void detectAndCompute(const Mat& img, const Mat& mask, vector<KeyPoint>& keypoints, Mat& descriptors);
	void getmaxMoment(Mat& dst);
	void getminMoment(Mat& dst);

private: // internal function
	void calcPhaseCongruency(const Mat& img, Mat& maxMoment, Mat& minMoment, vector<Mat>& Ao);

};

bool findTransform(const vector<KeyPoint>& queryKeypoints, const vector<KeyPoint>& trainKeypoints,
	vector<DMatch>& matches, Mat& homography, float reprojectionThreshold = 3.0);

}