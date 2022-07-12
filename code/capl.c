/*
 * Node3 - Simple node with address claiming       Version 1.0
 *
 * Copyright 2005, Vector Informatik GmbH - All right reserved
 *
 * History:
 * 1.0 (Jr) Created 
 */
variables
{
  // Constants
  const int  kNullAddr    = 0xfe;   // Null address
  const int  kGlobalAddr  = 0xff;   // Global address
  const int  kSuccess     = 0;      // Nodelayer function returns 0 on success

  const int  kInitialized = 0;      // 
  const int  kClaiming    = 1;      // 
  const int  kOnline      = 2;      // 
  const int  kOffline     = 3;      // 

  char gNodeName[32]      = "Node3"; // Name of the node, is used for output to write window

  // simulation constants

  // communication variables
  BYTE  gECUAddress       = kNullAddr;    // Address of this ECU
  BYTE  gECUState         = kInitialized; // Communication state of the ECU
  BYTE  gACLPending       = 0;            // 1, if sending ACL
  BYTE  gACLRqPending     = 0;            // 1, if sending request for ACL was received during address claiming

  pg ACL      TX_ACL;                     // TX Buffer: Address Claiming
  pg ACKM     TX_ACKM;                    // TX Buffer: Acknowledge
  pg HB_Node3 TX_HB;                      // Tx Buffer: Heartbeat
  msTimer     ACLTimer;                   // Timer for address claiming
  msTimer     TX_HB_Timer;

  // Definition of debugging constants
  const int kDbgInfo    = 10;
  const int kDbgWarning = 5;
  const int kDbgError   = 1;
  const int kDbgQuiet   = 0;

  // General global variables
  int gDbgLevel         = kDbgWarning; // Set debug level for output to write window
}