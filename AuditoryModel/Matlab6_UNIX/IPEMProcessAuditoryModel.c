/*
 * MATLAB Compiler: 3.0
 * Date: Thu Mar  3 12:02:03 2005
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-t" "-L" "C" "-W" "mex"
 * "IPEMProcessAuditoryModel.m" 
 */
#include "IPEMProcessAuditoryModel.h"
#include "IPEMHandleInputArguments.h"
#include "libmatlbm.h"
#include "IPEMProcessAuditoryModel_external.h"
static mxArray * _mxarray0_;

static mxChar _array4_[9] = { 'i', 'n', 'p', 'u', 't', '.', 'w', 'a', 'v' };
static mxArray * _mxarray3_;
static mxArray * _mxarray5_;

static mxChar _array7_[15] = { 'n', 'e', 'r', 'v', 'e', '_', 'i', 'm',
                               'a', 'g', 'e', '.', 'a', 'n', 'i' };
static mxArray * _mxarray6_;
static mxArray * _mxarray8_;
static mxArray * _mxarray9_;
static mxArray * _mxarray10_;

static mxArray * _array2_[8] = { NULL /*_mxarray3_*/, NULL /*_mxarray5_*/,
                                 NULL /*_mxarray6_*/, NULL /*_mxarray5_*/,
                                 NULL /*_mxarray8_*/, NULL /*_mxarray9_*/,
                                 NULL /*_mxarray0_*/, NULL /*_mxarray10_*/ };
static mxArray * _mxarray1_;

static mxChar _array12_[45] = { 'S', 'o', 'm', 'e', ' ', 'a', 'r', 'g', 'u',
                                'm', 'e', 'n', 't', 's', ' ', 'a', 'r', 'e',
                                ' ', 'n', 'o', 't', ' ', 'o', 'f', ' ', 't',
                                'h', 'e', ' ', 'c', 'o', 'r', 'r', 'e', 'c',
                                't', ' ', 't', 'y', 'p', 'e', '.', '.', '.' };
static mxArray * _mxarray11_;
static mxArray * _mxarray13_;
static mxArray * _mxarray14_;

static double _array16_[2] = { 1.0, 1.0 };
static mxArray * _mxarray15_;

static mxChar _array18_[52] = { 'S', 'o', 'm', 'e', ' ', 'a', 'r', 'g', 'u',
                                'm', 'e', 'n', 't', 's', ' ', 'd', 'o', ' ',
                                'n', 'o', 't', ' ', 'h', 'a', 'v', 'e', ' ',
                                't', 'h', 'e', ' ', 'c', 'o', 'r', 'r', 'e',
                                'c', 't', ' ', 'd', 'i', 'm', 'e', 'n', 's',
                                'i', 'o', 'n', 's', '.', '.', '.' };
static mxArray * _mxarray17_;

void InitializeModule_IPEMProcessAuditoryModel(void) {
    _mxarray0_ = mclInitializeDouble(2.0);
    _mxarray3_ = mclInitializeString(9, _array4_);
    _array2_[0] = _mxarray3_;
    _mxarray5_ = mclInitializeCharVector(0, 0, (mxChar *)NULL);
    _array2_[1] = _mxarray5_;
    _mxarray6_ = mclInitializeString(15, _array7_);
    _array2_[2] = _mxarray6_;
    _array2_[3] = _mxarray5_;
    _mxarray8_ = mclInitializeDouble(22050.0);
    _array2_[4] = _mxarray8_;
    _mxarray9_ = mclInitializeDouble(40.0);
    _array2_[5] = _mxarray9_;
    _array2_[6] = _mxarray0_;
    _mxarray10_ = mclInitializeDouble(.5);
    _array2_[7] = _mxarray10_;
    _mxarray1_ = mclInitializeCellVector(1, 8, _array2_);
    _mxarray11_ = mclInitializeString(45, _array12_);
    _mxarray13_ = mclInitializeDouble(-1.0);
    _mxarray14_ = mclInitializeDouble(1.0);
    _mxarray15_ = mclInitializeDoubleVector(1, 2, _array16_);
    _mxarray17_ = mclInitializeString(52, _array18_);
}

void TerminateModule_IPEMProcessAuditoryModel(void) {
    mxDestroyArray(_mxarray17_);
    mxDestroyArray(_mxarray15_);
    mxDestroyArray(_mxarray14_);
    mxDestroyArray(_mxarray13_);
    mxDestroyArray(_mxarray11_);
    mxDestroyArray(_mxarray1_);
    mxDestroyArray(_mxarray10_);
    mxDestroyArray(_mxarray9_);
    mxDestroyArray(_mxarray8_);
    mxDestroyArray(_mxarray6_);
    mxDestroyArray(_mxarray5_);
    mxDestroyArray(_mxarray3_);
    mxDestroyArray(_mxarray0_);
}

static mxArray * mlfIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(mxArray * inNumOfChannels,
                                                                          mxArray * inFirstFreq,
                                                                          mxArray * inFreqDist,
                                                                          mxArray * inInputFileName,
                                                                          mxArray * inInputFilePath,
                                                                          mxArray * inOutputFileName,
                                                                          mxArray * inOutputFilePath,
                                                                          mxArray * inSampleFrequency,
                                                                          mxArray * inSoundFileFormat);
static void mlxIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(int nlhs,
                                                                     mxArray * plhs[],
                                                                     int nrhs,
                                                                     mxArray * prhs[]);
static mxArray * MIPEMProcessAuditoryModel(int nargout_, mxArray * varargin);

static mexFunctionTableEntry local_function_table_[1]
  = { { "IPEMProcessAuditoryModelSafe",
        mlxIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe,
        9, 1, NULL } };

_mexLocalFunctionTable _local_function_table_IPEMProcessAuditoryModel
  = { 1, local_function_table_ };

/*
 * The function "mlfIPEMProcessAuditoryModel" contains the normal interface for
 * the "IPEMProcessAuditoryModel" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/PRIVATE/I
 * PEMProcessAuditoryModel.m" (lines 1-96). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
mxArray * mlfIPEMProcessAuditoryModel(mxArray * synthetic_varargin_argument,
                                      ...) {
    mxArray * varargin = NULL;
    int nargout = 1;
    mxArray * outResult = NULL;
    mlfVarargin(&varargin, synthetic_varargin_argument, 1);
    mlfEnterNewContext(0, -1, varargin);
    outResult = MIPEMProcessAuditoryModel(nargout, varargin);
    mlfRestorePreviousContext(0, 0);
    mxDestroyArray(varargin);
    return mlfReturnValue(outResult);
}

/*
 * The function "mlxIPEMProcessAuditoryModel" contains the feval interface for
 * the "IPEMProcessAuditoryModel" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/PRIVATE/I
 * PEMProcessAuditoryModel.m" (lines 1-96). The feval function calls the
 * implementation version of IPEMProcessAuditoryModel through this function.
 * This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
void mlxIPEMProcessAuditoryModel(int nlhs,
                                 mxArray * plhs[],
                                 int nrhs,
                                 mxArray * prhs[]) {
    mxArray * mprhs[1];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: IPEMProcessAuditoryModel Line: 1 Co"
            "lumn: 1 The function \"IPEMProcessAuditoryModel\" was cal"
            "led with more than the declared number of outputs (1)."),
          NULL);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = NULL;
    }
    mlfEnterNewContext(0, 0);
    mprhs[0] = NULL;
    mlfAssign(&mprhs[0], mclCreateVararginCell(nrhs, prhs));
    mplhs[0] = MIPEMProcessAuditoryModel(nlhs, mprhs[0]);
    mlfRestorePreviousContext(0, 0);
    plhs[0] = mplhs[0];
    mxDestroyArray(mprhs[0]);
}

/*
 * The function "mlfIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe"
 * contains the normal interface for the
 * "IPEMProcessAuditoryModel/IPEMProcessAuditoryModelSafe" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/PRIVATE/I
 * PEMProcessAuditoryModel.m" (lines 96-101). This function processes any input
 * arguments and passes them to the implementation version of the function,
 * appearing above.
 */
static mxArray * mlfIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(mxArray * inNumOfChannels,
                                                                          mxArray * inFirstFreq,
                                                                          mxArray * inFreqDist,
                                                                          mxArray * inInputFileName,
                                                                          mxArray * inInputFilePath,
                                                                          mxArray * inOutputFileName,
                                                                          mxArray * inOutputFilePath,
                                                                          mxArray * inSampleFrequency,
                                                                          mxArray * inSoundFileFormat) {
    int nargout = 1;
    mxArray * outResult = NULL;
    mlfEnterNewContext(
      0,
      9,
      inNumOfChannels,
      inFirstFreq,
      inFreqDist,
      inInputFileName,
      inInputFilePath,
      inOutputFileName,
      inOutputFilePath,
      inSampleFrequency,
      inSoundFileFormat);
    outResult
      = MIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(
          nargout,
          inNumOfChannels,
          inFirstFreq,
          inFreqDist,
          inInputFileName,
          inInputFilePath,
          inOutputFileName,
          inOutputFilePath,
          inSampleFrequency,
          inSoundFileFormat);
    mlfRestorePreviousContext(
      0,
      9,
      inNumOfChannels,
      inFirstFreq,
      inFreqDist,
      inInputFileName,
      inInputFilePath,
      inOutputFileName,
      inOutputFilePath,
      inSampleFrequency,
      inSoundFileFormat);
    return mlfReturnValue(outResult);
}

/*
 * The function "mlxIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe"
 * contains the feval interface for the
 * "IPEMProcessAuditoryModel/IPEMProcessAuditoryModelSafe" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/PRIVATE/I
 * PEMProcessAuditoryModel.m" (lines 96-101). The feval function calls the
 * implementation version of
 * IPEMProcessAuditoryModel/IPEMProcessAuditoryModelSafe through this function.
 * This function processes any input arguments and passes them to the
 * implementation version of the function, appearing above.
 */
static void mlxIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(int nlhs,
                                                                     mxArray * plhs[],
                                                                     int nrhs,
                                                                     mxArray * prhs[]) {
    mxArray * mprhs[9];
    mxArray * mplhs[1];
    int i;
    if (nlhs > 1) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: IPEMProcessAuditoryModel/IPEMProcess"
            "AuditoryModelSafe Line: 96 Column: 1 The function \"IPEMPr"
            "ocessAuditoryModel/IPEMProcessAuditoryModelSafe\" was call"
            "ed with more than the declared number of outputs (1)."),
          NULL);
    }
    if (nrhs > 9) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: IPEMProcessAuditoryModel/IPEMProces"
            "sAuditoryModelSafe Line: 96 Column: 1 The function \"IPEM"
            "ProcessAuditoryModel/IPEMProcessAuditoryModelSafe\" was c"
            "alled with more than the declared number of inputs (9)."),
          NULL);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = NULL;
    }
    for (i = 0; i < 9 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 9; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(
      0,
      9,
      mprhs[0],
      mprhs[1],
      mprhs[2],
      mprhs[3],
      mprhs[4],
      mprhs[5],
      mprhs[6],
      mprhs[7],
      mprhs[8]);
    mplhs[0]
      = MIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(
          nlhs,
          mprhs[0],
          mprhs[1],
          mprhs[2],
          mprhs[3],
          mprhs[4],
          mprhs[5],
          mprhs[6],
          mprhs[7],
          mprhs[8]);
    mlfRestorePreviousContext(
      0,
      9,
      mprhs[0],
      mprhs[1],
      mprhs[2],
      mprhs[3],
      mprhs[4],
      mprhs[5],
      mprhs[6],
      mprhs[7],
      mprhs[8]);
    plhs[0] = mplhs[0];
}

/*
 * The function "MIPEMProcessAuditoryModel" is the implementation version of
 * the "IPEMProcessAuditoryModel" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/PRIVATE/I
 * PEMProcessAuditoryModel.m" (lines 1-96). It contains the actual compiled
 * code for that M-function. It is a static function and must only be called
 * from one of the interface functions, appearing below.
 */
/*
 * function outResult = IPEMProcessAuditoryModel (varargin)
 */
static mxArray * MIPEMProcessAuditoryModel(int nargout_, mxArray * varargin) {
    mexLocalFunctionTable save_local_function_table_
      = mclSetCurrentLocalFunctionTable(
          &_local_function_table_IPEMProcessAuditoryModel);
    mxArray * outResult = NULL;
    mxArray * ans = NULL;
    mxArray * inFreqDist = NULL;
    mxArray * inFirstFreq = NULL;
    mxArray * inNumOfChannels = NULL;
    mxArray * inSampleFrequency = NULL;
    mxArray * inOutputFilePath = NULL;
    mxArray * inOutputFileName = NULL;
    mxArray * inInputFilePath = NULL;
    mxArray * inInputFileName = NULL;
    mclCopyArray(&varargin);
    /*
     * 
     * % Usage:
     * 
     * %   IPEMProcessAuditoryModel(inInputFileName,inInputFilePath,...
     * 
     * %                            inOutputFileName,inOutputFilePath,...
     * 
     * %                            inSampleFrequency,inNumOfChannels,...
     * 
     * %                            inFirstFreq,inFreqDist)
     * 
     * %
     * 
     * % Description:
     * 
     * %   Matlab interface function towards the auditory model developed by the
     * 
     * %   Department of Speech Processing of the Ghent University, partly adapted
     * 
     * %   by the IPEM.
     * 
     * %   This function takes a sound file and generates a file containing the auditory
     * 
     * %   nerve image corresponding to this sound file.
     * 
     * %
     * 
     * % Input arguments:
     * 
     * %   inInputFileName = name of the file to process (only .wav files)
     * 
     * %   inInputFilePath = directory path to the input file
     * 
     * %                     if empty or not specified, '' is used by default
     * 
     * %   inOutputFileName = name for the output file
     * 
     * %                      if empty or not specified, 'nerve_image.ani' is used by default
     * 
     * %   inOutputFilePath = directory path to the output file
     * 
     * %                      if empty or not specified, '' is used by default
     * 
     * %   inSampleFrequency = sample frequency of the wave file (in Hz)
     * 
     * %                       if empty or not specified, 22050 is used by default
     * 
     * %   inNumOfChannels = number of auditory channels
     * 
     * %                     if empty or not specified, 40 is used by default
     * 
     * %   inFirstFreq = center frequency for the first auditory channel (in cbu)
     * 
     * %                 if empty or not specified, 2.0 is used by default
     * 
     * %   inFreqDist = distance between center frequencies of two adjecent auditory channels (in cbu)
     * 
     * %                if empty or not specified, 0.5 is used by default
     * 
     * %
     * 
     * % Output:
     * 
     * %   outResult = if zero, processing was ok
     * 
     * %               otherwise, something went wrong...
     * 
     * %
     * 
     * % Authors:
     * 
     * %   Koen Tanghe - 19991118
     * 
     * % ------------------------------------------------------------------------------
     * 
     * 
     * 
     * % ------------------------------------------------------------------------------
     * 
     * % IPEM Toolbox - Toolbox for perception-based music analysis 
     * 
     * % Copyright (C) 2005 Ghent University
     * 
     * % 
     * 
     * % This program is free software; you can redistribute it and/or modify
     * 
     * % it under the terms of the GNU General Public License as published by
     * 
     * % the Free Software Foundation; either version 2 of the License, or
     * 
     * % (at your option) any later version.
     * 
     * % 
     * 
     * % This program is distributed in the hope that it will be useful,
     * 
     * % but WITHOUT ANY WARRANTY; without even the implied warranty of
     * 
     * % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     * 
     * % GNU General Public License for more details.
     * 
     * % 
     * 
     * % You should have received a copy of the GNU General Public License
     * 
     * % along with this program; if not, write to the Free Software
     * 
     * % Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
     * 
     * % ------------------------------------------------------------------------------
     * 
     * 
     * 
     * % Handle input arguments
     * 
     * [inInputFileName, inInputFilePath, inOutputFileName,inOutputFilePath,...
     * 
     * inSampleFrequency,inNumOfChannels, inFirstFreq, inFreqDist] = ...
     * 
     * IPEMHandleInputArguments(varargin,2,{'input.wav','','nerve_image.ani','',22050,40,2.0,0.5});
     */
    mlfNIPEMHandleInputArguments(
      0,
      mlfVarargout(
        &inInputFileName,
        &inInputFilePath,
        &inOutputFileName,
        &inOutputFilePath,
        &inSampleFrequency,
        &inNumOfChannels,
        &inFirstFreq,
        &inFreqDist,
        NULL),
      mclVa(varargin, "varargin"),
      _mxarray0_,
      _mxarray1_);
    /*
     * 
     * 
     * 
     * % Check types
     * 
     * if (~ischar(inInputFileName) | ~ischar(inInputFilePath) | ~ischar(inOutputFileName) ...
     */
    {
        mxArray * a_
          = mclInitialize(
              mclNot(mlfIschar(mclVv(inInputFileName, "inInputFileName"))));
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(mlfIschar(mclVv(inInputFilePath, "inInputFilePath")))));
        }
        if (mlfTobool(a_)) {
            /*
             * 
             * | ~ischar(inOutputFilePath) | ~isnumeric(inSampleFrequency) | ~isnumeric(inNumOfChannels) ...
             */
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIschar(mclVv(inOutputFileName, "inOutputFileName")))));
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIschar(mclVv(inOutputFilePath, "inOutputFilePath")))));
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIsnumeric(
                    mclVv(inSampleFrequency, "inSampleFrequency")))));
        }
        if (mlfTobool(a_)) {
            /*
             * 
             * | ~isnumeric(inFirstFreq) | ~isnumeric(inFreqDist))
             */
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIsnumeric(mclVv(inNumOfChannels, "inNumOfChannels")))));
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_, mclNot(mlfIsnumeric(mclVv(inFirstFreq, "inFirstFreq")))));
        }
        if (mlfTobool(a_)
            || mlfTobool(
                 mclOr(
                   a_,
                   mclNot(mlfIsnumeric(mclVv(inFreqDist, "inFreqDist")))))) {
            mxDestroyArray(a_);
            /*
             * 
             * disp('Some arguments are not of the correct type...');
             */
            mlfDisp(_mxarray11_);
            /*
             * 
             * outResult = -1;
             */
            mlfAssign(&outResult, _mxarray13_);
            /*
             * 
             * return;
             */
            goto return_;
        } else {
            mxDestroyArray(a_);
        }
    /*
     * 
     * end
     */
    }
    /*
     * 
     * 
     * 
     * % Check dimensions
     * 
     * if ((size(inInputFileName,1) ~= 1) | ((size(inInputFilePath,1) ~= 1) & ~isempty(inInputFilePath)) ...
     */
    {
        mxArray * a_
          = mclInitialize(
              mclNe(
                mlfSize(
                  mclValueVarargout(),
                  mclVv(inInputFileName, "inInputFileName"),
                  _mxarray14_),
                _mxarray14_));
        if (mlfTobool(a_)) {
            /*
             * 
             * | (size(inOutputFileName) ~= 1) | ((size(inOutputFilePath) ~= 1) & ~isempty(inOutputFilePath)) ...
             */
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mxArray * b_7
              = mclInitialize(
                  mclNe(
                    mlfSize(
                      mclValueVarargout(),
                      mclVv(inInputFilePath, "inInputFilePath"),
                      _mxarray14_),
                    _mxarray14_));
            if (mlfTobool(b_7)) {
                mlfAssign(
                  &b_7,
                  mclAnd(
                    b_7,
                    mclNot(
                      mlfIsempty(mclVv(inInputFilePath, "inInputFilePath")))));
            } else {
                mlfAssign(&b_7, mlfScalar(0));
            }
            mlfAssign(&a_, mclOr(a_, b_7));
            mxDestroyArray(b_7);
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNe(
                  mlfSize(
                    mclValueVarargout(),
                    mclVv(inOutputFileName, "inOutputFileName"),
                    NULL),
                  _mxarray14_)));
        }
        if (mlfTobool(a_)) {
            /*
             * 
             * | ~isequal(size(inSampleFrequency),[1,1]) | ~isequal(size(inNumOfChannels),[1,1]) ...
             */
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mxArray * b_3
              = mclInitialize(
                  mclNe(
                    mlfSize(
                      mclValueVarargout(),
                      mclVv(inOutputFilePath, "inOutputFilePath"),
                      NULL),
                    _mxarray14_));
            if (mlfTobool(b_3)) {
                mlfAssign(
                  &b_3,
                  mclAnd(
                    b_3,
                    mclNot(
                      mlfIsempty(
                        mclVv(inOutputFilePath, "inOutputFilePath")))));
            } else {
                mlfAssign(&b_3, mlfScalar(0));
            }
            mlfAssign(&a_, mclOr(a_, b_3));
            mxDestroyArray(b_3);
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIsequal(
                    mlfSize(
                      mclValueVarargout(),
                      mclVv(inSampleFrequency, "inSampleFrequency"),
                      NULL),
                    _mxarray15_, NULL))));
        }
        if (mlfTobool(a_)) {
            /*
             * 
             * | ~isequal(size(inFirstFreq),[1,1]) | ~isequal(size(inFreqDist),[1,1]))
             */
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIsequal(
                    mlfSize(
                      mclValueVarargout(),
                      mclVv(inNumOfChannels, "inNumOfChannels"),
                      NULL),
                    _mxarray15_, NULL))));
        }
        if (mlfTobool(a_)) {
            mlfAssign(&a_, mlfScalar(1));
        } else {
            mlfAssign(
              &a_,
              mclOr(
                a_,
                mclNot(
                  mlfIsequal(
                    mlfSize(
                      mclValueVarargout(),
                      mclVv(inFirstFreq, "inFirstFreq"),
                      NULL),
                    _mxarray15_, NULL))));
        }
        if (mlfTobool(a_)
            || mlfTobool(
                 mclOr(
                   a_,
                   mclNot(
                     mlfIsequal(
                       mlfSize(
                         mclValueVarargout(),
                         mclVv(inFreqDist, "inFreqDist"),
                         NULL),
                       _mxarray15_, NULL))))) {
            mxDestroyArray(a_);
            /*
             * 
             * disp('Some arguments do not have the correct dimensions...');
             */
            mlfDisp(_mxarray17_);
            /*
             * 
             * outResult = -1; 
             */
            mlfAssign(&outResult, _mxarray13_);
            /*
             * 
             * return;
             */
            goto return_;
        } else {
            mxDestroyArray(a_);
        }
    /*
     * 
     * end
     */
    }
    /*
     * 
     * 
     * 
     * % Process "safely" with the auditory model
     * 
     * outResult = IPEMProcessAuditoryModelSafe (...
     */
    mlfAssign(
      &outResult,
      mlfIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(
        mclVv(inNumOfChannels, "inNumOfChannels"),
        mclVv(inFirstFreq, "inFirstFreq"),
        mclVv(inFreqDist, "inFreqDist"),
        mclVv(inInputFileName, "inInputFileName"),
        mclVv(inInputFilePath, "inInputFilePath"),
        mclVv(inOutputFileName, "inOutputFileName"),
        mclVv(inOutputFilePath, "inOutputFilePath"),
        mclVv(inSampleFrequency, "inSampleFrequency"),
        _mxarray13_));
    /*
     * 
     * inNumOfChannels,inFirstFreq,inFreqDist,...
     * 
     * inInputFileName,inInputFilePath,inOutputFileName,inOutputFilePath,...
     * 
     * inSampleFrequency,-1);
     * 
     * 
     * 
     * 
     * 
     * % ------------------------------------------------------------------------------
     * 
     * %  "Safe" subfunction towards the actual C++/C/mex interface code.
     * 
     * %  Implemented externally.
     * 
     * %  See source code or documentation in IPEMAuditoryModel.hpp/cpp for detailed
     * 
     * %  explanation of the input arguments.
     * 
     * % ------------------------------------------------------------------------------
     */
    return_:
    mclValidateOutput(
      outResult, 1, nargout_, "outResult", "IPEMProcessAuditoryModel");
    mxDestroyArray(inInputFileName);
    mxDestroyArray(inInputFilePath);
    mxDestroyArray(inOutputFileName);
    mxDestroyArray(inOutputFilePath);
    mxDestroyArray(inSampleFrequency);
    mxDestroyArray(inNumOfChannels);
    mxDestroyArray(inFirstFreq);
    mxDestroyArray(inFreqDist);
    mxDestroyArray(ans);
    mxDestroyArray(varargin);
    mclSetCurrentLocalFunctionTable(save_local_function_table_);
    return outResult;
    /*
     * 
     */
}
