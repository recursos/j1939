/*@@var:*/
variables
{
  // Constants
  const float kPI              = 3.1415;
  const float kVehicleWeight   = 20000;  // Vehicle weight in [kg]
  const float kWheelRadius     = 0.4;    // Wheel radius in [m]
  const float kMaxEngineSpeed  = 2400.0; // Max. engine speed [rpm]
  const float kIdleEngineSpeed =  600.0; // Idle engine speed [rpm]

  // 
  const int   kSystemTime    = 100;                  // System time in [ms]
  const float kSystemTimeSec = kSystemTime / 1000.0; // System time in [sec]
  msTimer     SystemTimer;                           // System timer
}
/*@@end*/

/*@@timer:SystemTimer:*/
/*
 * System timer
 *
 * Simulation values are calculated in this timer.
 */
on timer SystemTimer
{
  float vehicleSpeed;
  float axleSpeed;
  float transmissionRatio;
  float engineSpeed;
  float driveForce;
  float engineTorque;
  float brakePedal;
  int   recalc;

  // get values
  transmissionRatio = getValue( EvTECU_GearRatio );            // [%]
  vehicleSpeed      = getValue( EvVECU_VehicleSpeed ) / 3.6;   // [m/s]
  engineTorque      = getValue( EvEMS_Torque );                // [Nm]
  brakePedal        = getValue( EvEBS_BrakePedalPos ) / 100.0; // [%]
  engineSpeed       = getValue( EvEMS_EngineSpeed );           // [rpm]

  // calculate forward force
  driveForce    = 0;
  if (   (transmissionRatio > 0) 
      && (engineSpeed < kMaxEngineSpeed) )
  {
    driveForce += engineTorque / transmissionRatio * kWheelRadius * 0.2;
  }
  driveForce   -= brakePedal * 60000; // brake force
  driveForce   -= (vehicleSpeed * vehicleSpeed) * 8; // Air resistance

  // caluclate simulated values
  vehicleSpeed += (driveForce / kVehicleWeight) * kSystemTimeSec;
  if (vehicleSpeed < 0) {
    vehicleSpeed  = 0;
  }
  axleSpeed = vehicleSpeed / 2 * kWheelRadius * kPI;

  // calculate engine speed
  if (transmissionRatio > 0) {
    engineSpeed = utilRange( axleSpeed / transmissionRatio, kIdleEngineSpeed, kMaxEngineSpeed);
  }

  // update envVars
  putValue( EvVECU_VehicleSpeed, vehicleSpeed * 3.6 );
  putValue( EvTECU_OutputShaftSpeed, axleSpeed );
  putValue( EvTECU_InputShaftSpeed, engineSpeed );
  if (transmissionRatio > 0) {
    putValue( EvEMS_SimulationMode, 1 );
    putValue( EvEMS_EngineSpeed, engineSpeed );
  }
  else {
    putValue( EvEMS_SimulationMode, 0 );
  }

  setTimer( SystemTimer, kSystemTime );
}
/*@@end*/

/*@@startStart:Start:*/
on start
{
  setTimer( SystemTimer, kSystemTime );
}
/*@@end*/

/*@@caplFunc:utilRange(float,float,float):*///function
/*
 * Clip the value to the range of min and max
 */
float utilRange( float value, float min, float max )
{
  if (value < min) return min;
  if (value > max) return max;

  return value;
}
/*@@end*/

