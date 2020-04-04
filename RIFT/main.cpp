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
	/* ��ȡͼƬ */
	string filePath = "optical-optical";
	Mat img_1 = imread(filePath + "/pair1.jpg", -1);
	Mat img_2 = imread(filePath + "/pair2.jpg", -1);

	/* ����RIFT������������� */
	vector<KeyPoint> keypoints_1, keypoints_2;
	Mat descriptors_1, descriptors_2;
	
	//Ptr<SIFT> detector = SIFT::create();
	//Ptr<SURF> detector = SURF::create();
	//Ptr<ORB> detector = ORB::create();
	Ptr<RIFT> detector = RIFT::create();

	chrono::steady_clock::time_point t1 = chrono::steady_clock::now();

	detector->detectAndCompute(img_1, Mat(), keypoints_1, descriptors_1);
	detector->detectAndCompute(img_2, Mat(), keypoints_2, descriptors_2);

	/* ����ƥ�� */
	Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
	vector<DMatch> matches, good_matches;
	matcher->match(descriptors_1, descriptors_2, matches);

	/* ���㵥Ӧ�Ծ��� */
	good_matches = matches;
	Mat homography;
	findTransform(keypoints_1, keypoints_2, good_matches, homography, 3.0);
	cout << "homography: " << homography << endl;

	chrono::steady_clock::time_point t2 = chrono::steady_clock::now();
	chrono::duration<double> time_used = chrono::duration_cast<chrono::duration<double>>(t2 - t1);
	cout << "time cost = " << time_used.count() << " seconds. " << endl;

	/* ���ƽ�� */
	Mat outimg_1, outimg_2;
	Mat img_match, img_goodmatch;
	drawKeypoints(img_1, keypoints_1, outimg_1, Scalar(0, 0, 255));
	drawKeypoints(img_2, keypoints_2, outimg_2, Scalar(0, 0, 255));
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, matches, img_match);
	drawMatches(img_1, keypoints_1, img_2, keypoints_2, good_matches, img_goodmatch);

	imshow("ԭʼͼ�� 1", img_1);
	imshow("ԭʼͼ�� 2", img_2);
	imshow("ͼ1������", outimg_1);
	imshow("ͼ2������", outimg_2);
	imshow("��ƥ����", img_match);
	imshow("��ƥ����", img_goodmatch);
	imwrite(filePath + "/result.jpg", img_goodmatch);

	waitKey();

	return 0;
}