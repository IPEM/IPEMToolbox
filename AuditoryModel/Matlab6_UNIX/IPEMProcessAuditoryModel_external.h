/*
 * MATLAB Compiler: 3.0
 * Date: Thu Mar  3 12:02:03 2005
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-t" "-L" "C" "-W" "mex"
 * "IPEMProcessAuditoryModel.m" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#ifndef __IPEMProcessAuditoryModel_external_h
#define __IPEMProcessAuditoryModel_external_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_IPEMProcessAuditoryModel_external(void);
extern void TerminateModule_IPEMProcessAuditoryModel_external(void);
extern mxArray * MIPEMProcessAuditoryModel_IPEMProcessAuditoryModelSafe(int nargout_,
                                                                        mxArray * inNumOfChannels,
                                                                        mxArray * inFirstFreq,
                                                                        mxArray * inFreqDist,
                                                                        mxArray * inInputFileName,
                                                                        mxArray * inInputFilePath,
                                                                        mxArray * inOutputFileName,
                                                                        mxArray * inOutputFilePath,
                                                                        mxArray * inSampleFrequency,
                                                                        mxArray * inSoundFileFormat);

#ifdef __cplusplus
}
#endif

#endif
