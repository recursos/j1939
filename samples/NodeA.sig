#<hr>
#Datei: <b>A simple J1939 Demo, Node A</b><p>
#Author: <b>Michael Eisele</b><p>
#Datum: <b>30.03.2006</b><p>
#<hr>

variables {
  CanMessage_AddressClaimed    msg_ac;

  timer tx_timer;
  timer ac_timer;

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

  int   address_valid;
}


int compare_names (char n1[], char n2[])
{
  int i;
  int ret = 0;
  for (i = 7; i >= 0; --i) {
    printf ("cn (%d): myName[%d]= %02x, otherName[%d]= %02x\n", i,i, n1[i] & 0xff, i,n2[i] & 0xff);
    if ((n1[i] & 0xff) < (n2[i] & 0xff)) {
      ret = -1;
      break;
    }
    else if ((n1[i] & 0xff) > (n2[i] & 0xff)) {
      ret = 1;
      break;
    }
  }
  return ret;
} /* compare_names */


void send_address_claimed ()
{
  //msg_ac.pgn = 0xee00;
  msg_ac.sa  = node_address;
  msg_ac.da  = 0xff;
  //msg_ac.pri = 3;

  msg_ac.flags = CANMSG_FLAG_EXT_ID;

  //msg_ac.dlc = 8;
  //
  //msg_ac.IdentityNumber.Raw          = name_identity_number;
  //msg_ac.ManufacturerCode.Raw        = name_manufacturer_code;
  //msg_ac.ECUInstance.Raw             = name_ecu_instance;
  //msg_ac.FunctionInstance.Raw        = name_function_instance;
  //msg_ac.Function.Raw                = name_function;
  //msg_ac.VehicleSystem.Raw           = name_vehicle_system;
  //msg_ac.VehicleSystemInstance.Raw   = name_vehicle_system_instance;
  //msg_ac.IndustryGroup.Raw           = name_industry_group;
  //msg_ac.ArbitraryAddressCapable.Raw = name_arbitrary_address_capable;

  canSendMessage (msg_ac);

  if (((node_address >= 0) && (node_address <= 127)) ||
      ((node_address >= 248) && (node_address <= 253))) {
    // Single Address CAs with addresses in the 0-127 and 248-253 ranges may omit the 250 ms delay.
    address_valid = 1;
  }

  if (!address_valid) timerStart (ac_timer);
} // send_address_claimed


on start {
  node_address = 128;

  name_arbitrary_address_capable = 0;
  name_industry_group            = 2;
  name_vehicle_system_instance   = 10;
  name_vehicle_system            = 5;
  name_function                  = 99;
  name_function_instance         = 11;
  name_ecu_instance              = 2;
  name_manufacturer_code         = 321;   // 0x141
  name_identity_number           = 76346; //0x12A3A

  // Setup global AddressClaimed message
  //msg_ac.pgn = 0xee00;
  msg_ac.sa  = node_address;
  msg_ac.da  = 0xff;
  msg_ac.pri = 3;

  msg_ac.flags = CANMSG_FLAG_EXT_ID;

  msg_ac.dlc = 8;

  msg_ac.IdentityNumber.Raw          = name_identity_number;
  msg_ac.ManufacturerCode.Raw        = name_manufacturer_code;
  msg_ac.ECUInstance.Raw             = name_ecu_instance;
  msg_ac.FunctionInstance.Raw        = name_function_instance;
  msg_ac.Function.Raw                = name_function;
  msg_ac.VehicleSystem.Raw           = name_vehicle_system;
  msg_ac.VehicleSystemInstance.Raw   = name_vehicle_system_instance;
  msg_ac.IndustryGroup.Raw           = name_industry_group;
  msg_ac.ArbitraryAddressCapable.Raw = name_arbitrary_address_capable;

  // printf ("*** Measurement started ***\n");
  address_valid = 0;
  ac_timer.timeout = 250;
  tx_timer.timeout = 500;
  timerStart (tx_timer);

  send_address_claimed ();
}


on timer ac_timer {
  address_valid = 1;
}


on CanMessage AddressClaimed {
  if ((this.flags & CANMSG_FLAG_TXACK) == 0) {
    if ((this.sa == node_address) && (node_address != 254)) {
      int cres = 0;

      cres = compare_names (msg_ac.data, this.data);

      printf ("Conflict: AddressClaimed: pgn=%d, pri=%d, sa=%02x, da=%02x, cres=%d\n",
              this.pgn,
              this.pri,
              this.sa,
              this.da,
              cres);

      timerCancel (ac_timer);

      if (cres < 0){
       printf("I (NodeA) win!\n");
       send_address_claimed ();
       }
      else {
        printf("I (NodeA) loose!\n");
        node_address = 254;
        address_valid = 1;
        send_address_claimed ();
      }
    }
  }
}



on action "Set Node Address" {
  int pi;
  int addr;
  pi = panelItemGetIdByName ("node_a_address");
  if (pi >= 0) {
    addr = panelItemGetValueInt (pi);
    printf ("New Address=%d\n", addr);
    node_address = addr;
    address_valid = 0;
    send_address_claimed ();
  }
}

on action "Toggle LED" {
  printf ("Toggle LED\n");
  led_on = !led_on;
  //printf ("Start sending\n");
  //timerStart (tx_timer);
}


on stopped {
  printf ("*** Stopped ***\n");
}


on timer tx_timer {
  CanMessage msg_led;

  timerStart (tx_timer);

  if (address_valid && (node_address != 254)) {
    if (led_on) msg_led.pgn = 92 << 8;
          else  msg_led.pgn = 94 << 8;

    msg_led.sa  = node_address;
    msg_led.da  = 0xff;
    msg_led.pri = 3;

    msg_led.flags = CANMSG_FLAG_EXT_ID;

    msg_led.dlc = 8;

    msg_led.data [0] = 0x00;
    msg_led.data [1] = 0x00;
    msg_led.data [2] = 0x00;
    msg_led.data [3] = 0x00;
    msg_led.data [4] = 0x00;
    msg_led.data [5] = 0x00;
    msg_led.data [6] = 0x00;
    msg_led.data [7] = 0x00;

    canSendMessage (msg_led);
  }
}


