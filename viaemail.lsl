//ViaEmail version 1.6 by Alan Martin

string send_address;
string receive_address;
float meters;

string name;
string chat_enabled = "off";
integer listen_event = 0;
list chat_messages;
list avatars = [];
integer distance;
integer checked = 0;
key notequery;
integer noteline = 0;
list prefs;

default
{
    state_entry()
    {
        notequery = llGetNotecardLine("Preferences",noteline);
        llOwnerSay("Welcome to ViaEmail, a solution for controlling SL from your inbox.");
        llOwnerSay("You can email me at: " + (string)llGetKey() +"@lsl.secondlife.com");
        llOwnerSay("Send an email with the subject 'help' to the above address for usage instructions after you have entered your email into the preferences notecard.");
        name = llKey2Name(llGetOwner());
        if(listen_event != 0)
        {
            llListenRemove(listen_event);
            chat_enabled = "off";
        }
        llSetTimerEvent(1.5);
        llListen(33,"",llGetOwner(),"");
    }
    
    on_rez(integer start_param)
    {
        notequery = llGetNotecardLine("Preferences",noteline);
        llOwnerSay("Welcome to ViaEmail, a solution for controlling SL from your inbox.");
        llOwnerSay("You can email me at: " + (string)llGetKey() +"@lsl.secondlife.com");
        llOwnerSay("Send an email with the subject 'help' to the above address for usage instructions after you have entered your email into the preferences notecard.");
        name = llKey2Name(llGetOwner());
    }
    
    changed(integer change)
    {
        if(change == CHANGED_INVENTORY)
        {
            notequery = llGetNotecardLine("Preferences",noteline);
        }
    }
    
    dataserver(key queryid, string data)
    {
        if(queryid == notequery)
        {
            if(data != "")
            {
                prefs += data;
                noteline = noteline + 1;
                notequery = llGetNotecardLine("Preferences",noteline);
            }
            else
            {
                send_address = llList2String(prefs, 0);
                if(llList2String(prefs, 1) == "none")
                {
                    receive_address = "";
                }
                else
                {
                    receive_address = llList2String(prefs, 1);
                }
                meters = llList2Float(prefs, 2);
                noteline = 0;
                prefs = [];
                llOwnerSay("Current Send Address: " + send_address + ", Current Receive Address: " + receive_address + ", Current Range: " + (string)llRound(meters) + " m");
                llOwnerSay("You can change these two addresses in the enclosed preferences notecard.");
            }
        }
    }
    
    touch_start(integer num_detected)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
            llOwnerSay("Current Send Address: " + send_address + ", Current Receive Address: " + receive_address + ", Current Range: " + (string)llRound(meters) + " m");
            llOwnerSay("You can change these two addresses and the range in the enclosed preferences notecard.");
            llOwnerSay("You can email me at: " + (string)llGetKey() +"@lsl.secondlife.com");
            llOwnerSay("Send an email with the subject 'help' to the above address for usage instructions.");
        }
    }
    
    timer()
    {
        if(checked == 1)
        {
            llEmail(send_address,"ViaEmail Avatar Scan","No avatars within " + (string)llRound(meters) + " meters.");
            checked = 0;
        }
        llGetNextEmail(receive_address,"");
    }
    
    email(string time, string address, string subj, string message, integer num_left)
    {
        if(subj == "help")
        {
            llEmail(send_address, "ViaEmail Help", "Thank you for using ViaEmail. To send commands to your ViaEmail device, simply send an email to " + (string)llGetKey() + "@lsl.secondlife.com with one of the following commands in the subject:\n \nsettext - Sets the floating text above your ViaEmail device to the body of the email.\nnearby - Tells ViaEmail to send you an email with the names of any avatars within " + (string)llRound(meters) + "m of it.\nsay - ViaEmail device says the body of the email on channel 0.\nshout - ViaEmail device shouts the body of the email on channel 0.\nchaton - Turns on fowarding of messages from channel 0 to your email address.\nchatoff - Turns off forwarding of messages from channel 0 to your email address.\nhelp - ViaEmail device sends you an email with usage instructions.\n \nYou can send the nearby, chaton, chatoff, and help commands to ViaEmail in SL on channel 33 (put a /33 before the command) if you are within chat range of your ViaEmail device.\n \nChat relay is " + chat_enabled + ".\nSend Address: " + send_address + "\nReceive Address: " + receive_address);
        }
        else if(subj == "settext")
        {
            llSetText(message,<1,1,1>,1.0);
        }
        else if(subj == "nearby")
        {
            llSetTimerEvent(0);
            checked = 1;
            llSensor("", "", AGENT, meters, PI);
            llSetTimerEvent(1.5);
        }
        else if(subj == "say")
        {
            llSay(0,name + ": " + message);
        }
        else if(subj == "shout")
        {
            llShout(0,name + ": " + message);
        }
        else if(subj == "chaton")
        {
            listen_event = llListen(0,"","","");
            chat_enabled = "on";
            llEmail(send_address,"ViaEmail Status","Chat relay has been enabled for ViaEmail. It will now forward any chat it hears on channel 0.\n \nDisable chat relay by sending an email with the subject 'chatoff' to ViaEmail (" + (string)llGetKey() +"@lsl.secondlife.com).");
        }
        else if(subj == "chatoff")
        {
            llListenRemove(listen_event);
            chat_enabled = "off";
            llEmail(send_address,"ViaEmail Status","Chat relay has been disabled for ViaEmail. It will not forward any more chat until it is enabled again.\n \nEnable chat relay by sending an email with the subject 'chaton' to ViaEmail (" + (string)llGetKey() +"@lsl.secondlife.com).");
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(channel == 0)
        {
            llEmail(send_address,"ViaEmail Chat Relay",name + ": " + message);
        }
        else if (channel == 33)
        {
            if(message == "nearby")
            {
                llSetTimerEvent(0);
                checked = 1;
                llSensor("", "", AGENT, meters, PI);
                llSetTimerEvent(1.5);
            }
            else if(message == "chaton")
            {
                listen_event = llListen(0,"","","");
                chat_enabled = "on";
                llEmail(send_address,"ViaEmail Status","Chat relay has been enabled for ViaEmail. It will now forward any chat it hears on channel 0.\n \nDisable chat relay by sending an email with the subject 'chatoff' to ViaEmail (" + (string)llGetKey() +"@lsl.secondlife.com).");
            }
            else if(message == "chatoff")
            {
                llListenRemove(listen_event);
                chat_enabled = "off";
                llEmail(send_address,"ViaEmail Status","Chat relay has been disabled for ViaEmail. It will not forward any more chat until it is enabled again.\n \nEnable chat relay by sending an email with the subject 'chaton' to ViaEmail (" + (string)llGetKey() +"@lsl.secondlife.com).");
            }
            else if(message == "help")
            {
                llEmail(send_address, "ViaEmail Help", "Thank you for using ViaEmail. To send commands to your ViaEmail device, simply send an email to " + (string)llGetKey() + "@lsl.secondlife.com with one of the following commands in the subject:\n \nsettext - Sets the floating text above your ViaEmail device to the body of the email.\nnearby - Tells ViaEmail to send you an email with the names of any avatars within " + (string)llRound(meters) + "m of it.\nsay - ViaEmail device says the body of the email on channel 0.\nshout - ViaEmail device shouts the body of the email on channel 0.\nchaton - Turns on fowarding of messages from channel 0 to your email address.\nchatoff - Turns off forwarding of messages from channel 0 to your email address.\nhelp - ViaEmail device sends you an email with usage instructions.\n \nYou can send the nearby, chaton, chatoff, and help commands to ViaEmail in SL on channel 33 (put a /33 before the command) if you are within chat range of your ViaEmail device.\n \nChat relay is " + chat_enabled + ".\nSend Address: " + send_address + "\nReceive Address: " + receive_address);
            }
        }
    }
    
    sensor(integer total_number)
    {
        integer i;
        for (i=0; i < total_number; i++)
        {
            distance = llRound(llVecDist(llGetPos(),llDetectedPos(i)));
            avatars += llDetectedName(i) + " is " + (string)distance + " meters away.";
        }
        llEmail(send_address,"ViaEmail Avatar Scan","Avatars within " + (string)llRound(meters) + " meters:\n \n" + llDumpList2String(avatars,"\n \n")); 
        checked = 0;
        avatars = [];
    }
}
