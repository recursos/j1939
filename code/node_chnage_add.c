/*
 * Change address
 */
on envVar EvNode1_ChangeAddress
{
  DWORD address;

  if (getValue(this) == 1) {
    address = getValue( EvNode1_NewAddress );
    if (address < kNullAddr) {
      Node1StartUp( address );
    }
    else {
      Node1ShutDown();
    }
  }
}