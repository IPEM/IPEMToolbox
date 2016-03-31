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

#include "libmatlb.h"
#include "IPEMProcessAuditoryModel.h"
#include "IPEMHandleInputArguments.h"

extern _mex_information _mex_info;

static mexFunctionTableEntry function_table[1]
  = { { "IPEMProcessAuditoryModel", mlxIPEMProcessAuditoryModel,
        -1, 1, &_local_function_table_IPEMProcessAuditoryModel } };

static _mexInitTermTableEntry init_term_table[1]
  = { { InitializeModule_IPEMProcessAuditoryModel,
        TerminateModule_IPEMProcessAuditoryModel } };

/*
 * The function "MIPEMHandleInputArguments" is the MATLAB callback version of
 * the "IPEMHandleInputArguments" function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/IPEMHandl
 * eInputArguments.m". It performs a callback to MATLAB to run the
 * "IPEMHandleInputArguments" function, and passes any resulting output
 * arguments back to its calling function.
 */
static mxArray * MIPEMHandleInputArguments(int nargout_,
                                           mxArray * inPassedArgs,
                                           mxArray * inNumFirstOptionalArg,
                                           mxArray * inDefaults) {
    mxArray * varargout = NULL;
    mclFevalCallMATLAB(
      mclNVarargout(nargout_, 1, &varargout, NULL),
      "IPEMHandleInputArguments",
      inPassedArgs, inNumFirstOptionalArg, inDefaults, NULL);
    return varargout;
}

/*
 * The function "mexLibrary" is a Compiler-generated mex wrapper, suitable for
 * building a MEX-function. It initializes any persistent variables as well as
 * a function table for use by the feval function. It then calls the function
 * "mlxIPEMProcessAuditoryModel". Finally, it clears the feval table and exits.
 */
mex_information mexLibrary(void) {
    mclMexLibraryInit();
    return &_mex_info;
}

_mex_information _mex_info
  = { 1, 1, function_table, 0, NULL, 0, NULL, 1, init_term_table };

/*
 * The function "mlfNIPEMHandleInputArguments" contains the nargout interface
 * for the "IPEMHandleInputArguments" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/IPEMHandl
 * eInputArguments.m" (lines 0-0). This interface is only produced if the
 * M-function uses the special variable "nargout". The nargout interface allows
 * the number of requested outputs to be specified via the nargout argument, as
 * opposed to the normal interface which dynamically calculates the number of
 * outputs based on the number of non-NULL inputs it receives. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
mxArray * mlfNIPEMHandleInputArguments(int nargout,
                                       mlfVarargoutList * varargout,
                                       mxArray * inPassedArgs,
                                       mxArray * inNumFirstOptionalArg,
                                       mxArray * inDefaults) {
    mlfEnterNewContext(0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout)
      = MIPEMHandleInputArguments(
          nargout, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    mlfRestorePreviousContext(
      0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfIPEMHandleInputArguments" contains the normal interface for
 * the "IPEMHandleInputArguments" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/IPEMHandl
 * eInputArguments.m" (lines 0-0). This function processes any input arguments
 * and passes them to the implementation version of the function, appearing
 * above.
 */
mxArray * mlfIPEMHandleInputArguments(mlfVarargoutList * varargout,
                                      mxArray * inPassedArgs,
                                      mxArray * inNumFirstOptionalArg,
                                      mxArray * inDefaults) {
    int nargout = 0;
    mlfEnterNewContext(0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    nargout += mclNargout(varargout);
    *mlfGetVarargoutCellPtr(varargout)
      = MIPEMHandleInputArguments(
          nargout, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    mlfRestorePreviousContext(
      0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    return mlfAssignOutputs(varargout);
}

/*
 * The function "mlfVIPEMHandleInputArguments" contains the void interface for
 * the "IPEMHandleInputArguments" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/IPEMHandl
 * eInputArguments.m" (lines 0-0). The void interface is only produced if the
 * M-function uses the special variable "nargout", and has at least one output.
 * The void interface function specifies zero output arguments to the
 * implementation version of the function, and in the event that the
 * implementation version still returns an output (which, in MATLAB, would be
 * assigned to the "ans" variable), it deallocates the output. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlfVIPEMHandleInputArguments(mxArray * inPassedArgs,
                                  mxArray * inNumFirstOptionalArg,
                                  mxArray * inDefaults) {
    mxArray * varargout = NULL;
    mlfEnterNewContext(0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    varargout
      = MIPEMHandleInputArguments(
          0, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    mlfRestorePreviousContext(
      0, 3, inPassedArgs, inNumFirstOptionalArg, inDefaults);
    mxDestroyArray(varargout);
}

/*
 * The function "mlxIPEMHandleInputArguments" contains the feval interface for
 * the "IPEMHandleInputArguments" M-function from file
 * "/afs/cmb.ucdavis.edu/share/matlab/janata/models/IPEMToolbox/Common/IPEMHandl
 * eInputArguments.m" (lines 0-0). The feval function calls the implementation
 * version of IPEMHandleInputArguments through this function. This function
 * processes any input arguments and passes them to the implementation version
 * of the function, appearing above.
 */
void mlxIPEMHandleInputArguments(int nlhs,
                                 mxArray * plhs[],
                                 int nrhs,
                                 mxArray * prhs[]) {
    mxArray * mprhs[3];
    mxArray * mplhs[1];
    int i;
    if (nrhs > 3) {
        mlfError(
          mxCreateString(
            "Run-time Error: File: IPEMHandleInputArguments Line: 1 Co"
            "lumn: 1 The function \"IPEMHandleInputArguments\" was cal"
            "led with more than the declared number of inputs (3)."),
          NULL);
    }
    for (i = 0; i < 1; ++i) {
        mplhs[i] = NULL;
    }
    for (i = 0; i < 3 && i < nrhs; ++i) {
        mprhs[i] = prhs[i];
    }
    for (; i < 3; ++i) {
        mprhs[i] = NULL;
    }
    mlfEnterNewContext(0, 3, mprhs[0], mprhs[1], mprhs[2]);
    mplhs[0] = MIPEMHandleInputArguments(nlhs, mprhs[0], mprhs[1], mprhs[2]);
    mclAssignVarargoutCell(0, nlhs, plhs, mplhs[0]);
    mlfRestorePreviousContext(0, 3, mprhs[0], mprhs[1], mprhs[2]);
}
