#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/xfeatures2d.hpp> // SIFT
#include <chrono>
#include "rift.h"

using namespace std;
using namespace cv;
using namespace xfeatures2d;

int main()
{
	/* 读取图片 */
	string filePath = "optical-optical";
	Mat img_1 = imread(filePath + "/pair1.jpg", -1);
	Mat img_2 = imread(filePath + "/pair2.jpg", -1);

	/* 计算RIFT特征点和描述子 */
	vector<KeyPoint> keypoints_1, keypoints_2;
	Mat descriptors_1, descriptors_2;
	
	//Ptr<SIFT> detector = SIFT::create();
	//Ptr<SURF> detector = SURF::create();
	//Ptr<ORB> detector = ORB::create();
	Ptr<RIFT> detector = RIFT::create();

	chrono::steady_clock::time_point t1 = chrono::steady_clock::now();

	detector->detectAndCompute(img_1, Mat(), keypoints_1, descriptors_1);
	detector->detectAndCompute(img_2, Mat(), keypoints_2, descriptors_2);

	/* 特征匹配 */
	Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
	vector<DMatch> matches, good_matches;
	matcher->match(descriptors_1, descriptors_2, matches);

	/* 计算单应性矩阵 */
	good_matches = matches;
	Mat homography;
	findTransform(keypoints_1, keypoints_2, good_matches, homography, 3.0);
	cout << "homography: " << homography << endl;

	chrono::steady_clock::time_point t2 = chrono::steady_clock::now();
	chrono::duration<double> time_used = chrono::duration_cast<chrono::duration<double>>(t2 - t1);
	cout << "time cost = " << time_used.count() << " seconds. " << endl;

	/* 绘制结果 */
	Mat outimg_1, outimg_2;
	Mat img_match, img_goodmatch;
	drawKeypoints(img_1, keypoints_1, outimg_1, Scalar(0, 0, 255));
	drawKeypoints(img_2, keypoints_2, outimg_2, Scalar(0, 0, 255));
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, matches, img_match);
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, good_matches, img_goodmatch);

	imshow("原始图像 1", img_1);
	imshow("原始图像 2", img_2);
	imshow("图1特征点", outimg_1);
	imshow("图2特征点", outimg_2);
	imshow("粗匹配结果", img_match);
	imshow("精匹配结果", img_goodmatch);
	imwrite(filePath + "/result.jpg", img_goodmatch);

	waitKey();

	return 0;
}