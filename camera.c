//
// This is a hack of the f00Dave's CameraB.cpp Descent style camera demo.
// I converted it to C and removed cut it down to just the camera routines.
//

// System includes.
#include <math.h>

#include "platform.h"

// Local includes.
#include "f00QuatC.h"

#define bool int
#define true 1
#define false 0

//
// Some local settings, play with them at your own peril....
//

#define DEF_keyboardAngleStep		5.0
#define DEF_truckStepSize		100 

//
// Icky camera globals. :-/
//

// Position
GLfloat		camX = 0.0;
GLfloat		camY = 0.0;
GLfloat		camZ = 0.0;

// Orientation
// Note:  We will be storing this 'pre-inverted'.  This means the quat is always ready for
// application, and does not need to be inverted, like the position variables....
// This *does* require us to invert the directions used to modify the quat, however.
// Win some, lose some....
f00Quat		camOrient;

/***************************************************************/
// This is called when we wish to apply the viewpoint transformations.
void
applyCamera()
{
  GLfloat rotMatrix[ 16 ];

  // Apply the current orientation....
  f00Quat_getMatrix( &camOrient, rotMatrix );
  glMultMatrixf( rotMatrix );

  // ... and translation.
  glTranslatef( -camX, -camY, -camZ );
}

/***************************************************************/
// This is called when we wish to reset the viewpoint.
void 
resetCamera()
{
  // Reset the position
  camX = 0.0;
  camY = 0.0;
  camZ = 0.0;

  // and the orientation
  f00Quat_reset(&camOrient);
}

/***************************************************************/
// This is called when we want to 'truck' the camera (ie: move it, relative to it's
// current orientation).
void
truckCamera( GLfloat truckBy, bool truckX, bool truckY, bool truckZ )
{
  GLfloat dirX;
  GLfloat dirY;
  GLfloat dirZ;
		
  f00Quat truckQuat;
  f00Quat_copy( &truckQuat, &camOrient );

  if( truckZ )
  {
    ;	// Don't do anything....
  }
  else if( truckX )
  {
    f00Quat_postMult_3( &truckQuat, 0.0, -90.0, 0.0 );		
  }
  else if( truckY )
  {
    f00Quat_postMult_3( &truckQuat, 90.0, 0.0, 0.0 );		
  }

  // Ask the Quat class for a unit vector, aligned with the orientation.
  f00Quat_getDirectionVector( &truckQuat, &dirX, &dirY, &dirZ );

  // Use the values to update the position....
  camX += dirX * truckBy;
  camY += dirY * truckBy;
  camZ += dirZ * truckBy;
}

#pragma argsused
// We trap 'special' keystrokes here.
void
specialFunc( int key, int x, int y )
{
  int glutModifiers = glutGetModifiers();

  // Ctrl Arrow keys truck left, right, up, down.
  if (glutModifiers & GLUT_ACTIVE_CTRL)
  switch( key )
  {
  // Move forwards.
  case GLUT_KEY_PAGE_UP:
    truckCamera( -DEF_truckStepSize, false, false, true );
    break;
  // Move backwards.
  case GLUT_KEY_PAGE_DOWN:
    truckCamera( DEF_truckStepSize, false, false, true );
    break;
  // Strafe left.
  case GLUT_KEY_LEFT:
    truckCamera( -DEF_truckStepSize, true, false, false );
    break;
  // Strafe right.
  case GLUT_KEY_RIGHT:
    truckCamera( DEF_truckStepSize, true, false, false );
    break;
  // Strafe up.
  case GLUT_KEY_UP:
    truckCamera( DEF_truckStepSize, false, true, false );
    break;
  // Strafe down.
  case GLUT_KEY_DOWN:
    truckCamera( -DEF_truckStepSize, false, true, false );
    break;
  }
  // Alt Arrow keys roll left, right, up, down.
  else if (glutModifiers & GLUT_ACTIVE_ALT)
  switch( key )
  {
  // Move forwards.
  case GLUT_KEY_PAGE_UP:
    truckCamera( -DEF_truckStepSize, false, false, true );
    break;
  // Move backwards.
  case GLUT_KEY_PAGE_DOWN:
    truckCamera( DEF_truckStepSize, false, false, true );
    break;
  // Roll to the left (counterclockwise).
  case GLUT_KEY_LEFT:
    f00Quat_postMult_3( &camOrient, 0.0, 0.0, -DEF_keyboardAngleStep );
    break;
  // Roll to the right (clockwise).
  case GLUT_KEY_RIGHT:
    f00Quat_postMult_3( &camOrient, 0.0, 0.0, DEF_keyboardAngleStep );
    break;
  // Look up.
  case GLUT_KEY_UP:
    f00Quat_postMult_3( &camOrient, DEF_keyboardAngleStep, 0.0, 0.0 );
    break;
  // Look down.
  case GLUT_KEY_DOWN:
    f00Quat_postMult_3( &camOrient, -DEF_keyboardAngleStep, 0.0, 0.0 );
    break;
  }
  else
  switch( key )
  {
  // Move forwards.
  case GLUT_KEY_PAGE_UP:
    truckCamera( -DEF_truckStepSize, false, false, true );
    break;
  // Move backwards.
  case GLUT_KEY_PAGE_DOWN:
    truckCamera( DEF_truckStepSize, false, false, true );
    break;
  // Turn left.
  case GLUT_KEY_LEFT:
    f00Quat_postMult_3( &camOrient, 0.0, -DEF_keyboardAngleStep, 0.0 );
    break;
  // Turn right.
  case GLUT_KEY_RIGHT:
    f00Quat_postMult_3( &camOrient, 0.0, DEF_keyboardAngleStep, 0.0 );
    break;
  // Look up.
  case GLUT_KEY_UP:
    f00Quat_postMult_3( &camOrient, DEF_keyboardAngleStep, 0.0, 0.0 );
    break;
  // Look down.
  case GLUT_KEY_DOWN:
    f00Quat_postMult_3( &camOrient, -DEF_keyboardAngleStep, 0.0, 0.0 );
    break;
  }
}


