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

#ifndef __IPEMHandleInputArguments_h
#define __IPEMHandleInputArguments_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_IPEMHandleInputArguments(void);
extern void TerminateModule_IPEMHandleInputArguments(void);
extern _mexLocalFunctionTable _local_function_table_IPEMHandleInputArguments;

extern mxArray * mlfNIPEMHandleInputArguments(int nargout,
                                              mlfVarargoutList * varargout,
                                              mxArray * inPassedArgs,
                                              mxArray * inNumFirstOptionalArg,
                                              mxArray * inDefaults);
extern mxArray * mlfIPEMHandleInputArguments(mlfVarargoutList * varargout,
                                             mxArray * inPassedArgs,
                                             mxArray * inNumFirstOptionalArg,
                                             mxArray * inDefaults);
extern void mlfVIPEMHandleInputArguments(mxArray * inPassedArgs,
                                         mxArray * inNumFirstOptionalArg,
                                         mxArray * inDefaults);
extern void mlxIPEMHandleInputArguments(int nlhs,
                                        mxArray * plhs[],
                                        int nrhs,
                                        mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
