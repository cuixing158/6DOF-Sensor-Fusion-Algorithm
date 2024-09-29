/*
 * xyz_filter.c
 *
 * Code generation for function 'xyz_filter'
 *
 * C source code generated on: Wed Jan 15 15:17:53 2014
 *
 */

/* Include files */
#include "xyz_filter.h"

/* Type Definitions */
#ifndef struct_dsp_BiquadFilter_0
#define struct_dsp_BiquadFilter_0

struct dsp_BiquadFilter_0
{
  boolean_T S0_isInitialized;
  boolean_T S1_isReleased;
  double W0_FILT_STATES[6];
  double P0_ICRTP;
  double P1_RTP1COEFF[3];
  double P2_RTP2COEFF[2];
  double P3_RTP3COEFF[2];
  boolean_T P4_RTP_COEFF3_BOOL[2];
};

#endif                                 /*struct_dsp_BiquadFilter_0*/

#ifndef typedef_dsp_BiquadFilter_0
#define typedef_dsp_BiquadFilter_0

typedef struct dsp_BiquadFilter_0 dsp_BiquadFilter_0;

#endif                                 /*typedef_dsp_BiquadFilter_0*/

#ifndef typedef_dspcodegen_BiquadFilter
#define typedef_dspcodegen_BiquadFilter

typedef struct {
  boolean_T isInitialized;
  boolean_T isReleased;
  unsigned int inputVarSize1[8];
  boolean_T inputDirectFeedthrough1;
  dsp_BiquadFilter_0 cSFunObject;
} dspcodegen_BiquadFilter;

#endif                                 /*typedef_dspcodegen_BiquadFilter*/

/* Variable Definitions */
static dspcodegen_BiquadFilter hFilter;
static boolean_T hFilter_not_empty;

/* Function Declarations */
static dspcodegen_BiquadFilter *BiquadFilter_BiquadFilter
  (dspcodegen_BiquadFilter *obj);
static void Destructor(dsp_BiquadFilter_0 *obj);
static void xyz_filter_free(void);

/* Function Definitions */
static dspcodegen_BiquadFilter *BiquadFilter_BiquadFilter
  (dspcodegen_BiquadFilter *obj)
{
  dspcodegen_BiquadFilter *b_obj;
  dspcodegen_BiquadFilter *c_obj;
  dsp_BiquadFilter_0 *d_obj;
  int i;
  static const signed char iv1[3] = { 1, 2, 1 };

  static const double dv0[2] = { -1.9911142922016536, 0.99115359586893537 };

  static const boolean_T bv0[2] = { TRUE, FALSE };

  b_obj = obj;
  c_obj = b_obj;
  c_obj->isInitialized = FALSE;
  c_obj->isReleased = FALSE;
  c_obj->inputDirectFeedthrough1 = FALSE;
  d_obj = &b_obj->cSFunObject;

  /* System object Constructor function: dsp.BiquadFilter */
  d_obj->S0_isInitialized = FALSE;
  d_obj->S1_isReleased = FALSE;
  d_obj->P0_ICRTP = 0.0;
  for (i = 0; i < 3; i++) {
    d_obj->P1_RTP1COEFF[i] = iv1[i];
  }

  for (i = 0; i < 2; i++) {
    d_obj->P2_RTP2COEFF[i] = dv0[i];
    d_obj->P3_RTP3COEFF[i] = 9.8259168204820344E-6 + -9.8259168204820344E-6 *
      (double)i;
    d_obj->P4_RTP_COEFF3_BOOL[i] = bv0[i];
  }

  return b_obj;
}

static void Destructor(dsp_BiquadFilter_0 *obj)
{
  /* System object Destructor function: dsp.BiquadFilter */
  if (obj->S0_isInitialized) {
    obj->S0_isInitialized = FALSE;
    if (!obj->S1_isReleased) {
      obj->S1_isReleased = TRUE;
    }
  }
}

static void xyz_filter_free(void)
{
  Destructor(&hFilter.cSFunObject);
}

void xyz_filter(double x, double y, double z, double xyz_out[3])
{
  dspcodegen_BiquadFilter *obj;
  double varargin_1[3];
  int k;
  static const signed char value[8] = { 1, 3, 1, 1, 1, 1, 1, 1 };

  dsp_BiquadFilter_0 *b_obj;
  boolean_T exitg1;
  static const signed char iv0[8] = { 1, 3, 1, 1, 1, 1, 1, 1 };

  int ioIdx;
  int memOffset;
  double stageIn;
  double numAccum;
  double stageOut;
  if (!hFilter_not_empty) {
    BiquadFilter_BiquadFilter(&hFilter);
    hFilter_not_empty = TRUE;
  }

  obj = &hFilter;
  varargin_1[0] = x;
  varargin_1[1] = y;
  varargin_1[2] = z;
  if (!obj->isInitialized) {
    obj->isInitialized = TRUE;
    for (k = 0; k < 8; k++) {
      obj->inputVarSize1[k] = (unsigned int)value[k];
    }

    b_obj = &obj->cSFunObject;
    if (!b_obj->S0_isInitialized) {
      b_obj->S0_isInitialized = TRUE;

      /* System object Initialization function: dsp.BiquadFilter */
      for (k = 0; k < 6; k++) {
        b_obj->W0_FILT_STATES[k] = b_obj->P0_ICRTP;
      }
    }

    b_obj = &obj->cSFunObject;

    /* System object Initialization function: dsp.BiquadFilter */
    for (k = 0; k < 6; k++) {
      b_obj->W0_FILT_STATES[k] = b_obj->P0_ICRTP;
    }
  }

  k = 0;
  exitg1 = FALSE;
  while ((exitg1 == FALSE) && (k < 8)) {
    if (obj->inputVarSize1[k] != (unsigned int)iv0[k]) {
      for (k = 0; k < 8; k++) {
        obj->inputVarSize1[k] = (unsigned int)value[k];
      }

      exitg1 = TRUE;
    } else {
      k++;
    }
  }

  b_obj = &obj->cSFunObject;
  if (!b_obj->S0_isInitialized) {
    b_obj->S0_isInitialized = TRUE;

    /* System object Initialization function: dsp.BiquadFilter */
    for (k = 0; k < 6; k++) {
      b_obj->W0_FILT_STATES[k] = b_obj->P0_ICRTP;
    }
  }

  /* System object Outputs function: dsp.BiquadFilter */
  ioIdx = 0;
  for (k = 0; k < 3; k++) {
    memOffset = k << 1;
    stageIn = b_obj->P3_RTP3COEFF[0U] * varargin_1[ioIdx];
    numAccum = b_obj->W0_FILT_STATES[memOffset];
    numAccum += b_obj->P1_RTP1COEFF[0] * stageIn;
    stageOut = numAccum;
    numAccum = b_obj->W0_FILT_STATES[memOffset + 1];
    numAccum += b_obj->P1_RTP1COEFF[1] * stageIn;
    numAccum -= b_obj->P2_RTP2COEFF[0] * stageOut;
    b_obj->W0_FILT_STATES[memOffset] = numAccum;
    numAccum = b_obj->P1_RTP1COEFF[2] * stageIn;
    numAccum -= b_obj->P2_RTP2COEFF[1] * stageOut;
    b_obj->W0_FILT_STATES[memOffset + 1] = numAccum;
    xyz_out[ioIdx] = stageOut;
    ioIdx++;
  }
}

void xyz_filter_initialize(void)
{
  hFilter_not_empty = FALSE;
}

void xyz_filter_terminate(void)
{
  xyz_filter_free();
}

/* End of code generation (xyz_filter.c) */
