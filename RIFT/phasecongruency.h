#pragma once
#include <vector>
#include <opencv2/opencv.hpp>
#define _USE_MATH_DEFINES
#include <math.h>

using namespace std;
using namespace cv;

#define MAT_TYPE CV_64FC1
#define MAT_TYPE_CNV CV_64F


struct PhaseCongruencyConst 
{
    double sigma;
    double mult = 2.0;
    double minwavelength = 1.5;
    double epsilon = 0.0002;
    double cutOff = 0.4;
    double g = 10.0;
    double k = 10.0;
    PhaseCongruencyConst();
    PhaseCongruencyConst(const PhaseCongruencyConst& _pcc);
    PhaseCongruencyConst& operator=(const PhaseCongruencyConst& _pcc);
};

class PhaseCongruency
{
public:
	PhaseCongruency(Size _img_size, size_t _nscale, size_t _norient);
	~PhaseCongruency() {}
    void setConst(PhaseCongruencyConst _pcc);
    void calc(InputArray _src, vector<Mat> &_pc, vector<Mat>& _Ao);
    void feature(vector<Mat> &_pc, OutputArray _edges, OutputArray _corners);
    void feature(InputArray _src, cv::OutputArray _edges, OutputArray _corners);

private:
    Size size;
    size_t norient;
    size_t nscale;

    PhaseCongruencyConst pcc;

    vector<Mat> filter;
};