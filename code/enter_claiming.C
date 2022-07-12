/*
 * Start address claiming
 */
void EnterClaiming()
{
  cancelTimer( ACLTimer );
  cancelTimer( TX_HB_Timer );

  // send address claiming PG and wait 250ms
  TX_ACL.SA = gECUAddress;
  TX_ACL.DA = kGlobalAddr;
  TX_ACL.ArbitraryAddressCapable = Node3.NmJ1939AAC;
  TX_ACL.IndustryGroup           = Node3.NmJ1939IndustryGroup;
  TX_ACL.VehicleSystem           = Node3.NmJ1939System;
  TX_ACL.VehicleSystemInstance   = Node3.NmJ1939SystemInstance;
  TX_ACL.Function                = Node3.NmJ1939Function;
  TX_ACL.FunctionInstance        = Node3.NmJ1939FunctionInstance;
  TX_ACL.ECUInstance             = Node3.NmJ1939ECUInstance;
  TX_ACL.ManufacturerCode        = Node3.NmJ1939ManufacturerCode;
  TX_ACL.IdentityNumber          = Node3.NmJ1939IdentityNumber;

  gACLPending = 1;

  output( TX_ACL );

  putValue( EvNode3_Address, kNullAddr );

  setTimer( ACLTimer, 250 );

  writeDbgLevel( kDbgInfo, "<%s> start address claiming for address %d", gNodeName, TX_ACL.SA );
}