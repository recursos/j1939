#<hr>
#Datei: <b>A simple J1939 Demo, Node B</b><p>
#Author: <b>Michael Eisele</b><p>
#Datum: <b>30.03.2006</b><p>
#<hr>

variables {
  int   node_address;

  int   name_arbitrary_address_capable,
        name_industry_group,
        name_vehicle_system_instance,
        name_vehicle_system,
        name_function,
        name_function_instance,
        name_ecu_instance,
        name_manufacturer_code,
        name_identity_number;

  int   led_on;
  int   address_ok;
  timer ac_timer;
}


signal [0,1] (continuous) "SignalLedState";


void send_address_claimed ()
{
  CanMessage msg_ac;

  msg_ac.pgn = 0xee00;
  msg_ac.sa  = node_address;
  msg_ac.da  = 0xff;
  msg_ac.pri = 3;

  msg_ac.flags = CANMSG_FLAG_EXT_ID;

  msg_ac.dlc = 8;

  msg_ac.data [0] = name_identity_number & 0xff;
  msg_ac.data [1] = (name_identity_number >> 8) & 0xff;
  msg_ac.data [2] = (name_identity_number >> 16) & 0x1f;
  msg_ac.data [2] |= (name_manufacturer_code & 0x07) << 5;
  msg_ac.data [3] = (name_manufacturer_code >> 3) & 0xff;
  msg_ac.data [4] = name_ecu_instance & 0x07;
  msg_ac.data [4] |= name_function_instance << 3;
  msg_ac.data [5] = name_function;
  msg_ac.data [6] = name_vehicle_system << 1;
  msg_ac.data [7] = name_vehicle_system_instance & 0x0f;
  msg_ac.data [7] |= (name_industry_group & 0x07) << 4;
  msg_ac.data [7] |= (name_arbitrary_address_capable & 0x01) << 7;

  canSendMessage (msg_ac);
  if (!address_ok) timerStart (ac_timer);
} // send_address_claimed


on start {
  led_on = 0;
  signalSetValueInt (SignalLedState, led_on);

  node_address = 129;
  address_ok = 0;
  ac_timer.timeout = 1000;

  name_arbitrary_address_capable = 0;
  name_industry_group            = 2;
  name_vehicle_system_instance   = 10;
  name_vehicle_system            = 5;
  name_function                  = 98;
  name_function_instance         = 11;
  name_ecu_instance              = 2;
  name_manufacturer_code         = 321;
  name_identity_number           = 12345;

  // printf ("*** Measurement started ***\n");
  send_address_claimed ();
}


on timer ac_timer {
  address_ok = 1;
}


on CanMessage 0xee00 x { // or: on CanMessage 60928 x {
  if ((this.flags & CANMSG_FLAG_TXACK) == 0) {
    printf ("Msg: AddressClaimed: pgn=%d, pri=%d, sa=%02x, da=%02x\n",
            this.pgn,
            this.pri,
            this.sa,
            this.da);

    if (this.sa == node_address) {
      timerCancel (ac_timer);
      if (address_ok) send_address_claimed ();
      else node_address = 254;
    }
  }
}


on stopped {
  //printf ("*** Stopped ***\n");
}


on CanMessage 0x5c00 x {
  led_on = 1;
  signalSetValueInt (SignalLedState, led_on);
  //printf ("NodeB: LED ON\n");
}


on CanMessage 0x5e00 x {
  led_on = 0;
  signalSetValueInt (SignalLedState, led_on);
  //printf ("NodeB: LED OFF\n");
}



