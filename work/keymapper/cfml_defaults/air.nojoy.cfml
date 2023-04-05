<controlset version = "1.0.0" keyboard = "us" language = "english" >
	<control>
		<function>gear handle</function>
		<key>g</key>
	</control>
	<control>
		<function>instrument view</function>
		<key>numpad 0</key>
	</control>
	<control>
		<function>gunsight view</function>
		<key>numpad .</key>
	</control>
	<control>
		<function>bombsight speed decrease</function>
		<key>end</key>
	</control>
	<control>
		<function>bombsight speed increase</function>
		<key>home</key>
	</control>
	<control>
		<function>bombsight alt decrease</function>
		<key>page down</key>
	</control>	
	<control>
		<function>bombsight alt increase</function>
		<key>page up</key>
	</control>			

	<control>
		<function>turret traverse</function>
		<mouseaxis>x</mouseaxis>
		<keyabsolute value="0.00" onrelease="50.00" index="10">
			<key>left shift</key>
			<key>a</key>
		</keyabsolute>
		<keyabsolute value="40.00" onrelease="50.00" index="4">
			<key>a</key>
		</keyabsolute>
		<keyabsolute value="60.00" onrelease="50.00" index="6">
			<key>d</key>
		</keyabsolute>
		<keyabsolute value="100.00" onrelease="50.00" index="10">
			<key>left shift</key>
			<key>d</key>
		</keyabsolute>
	</control>	
	<control>
		<function>turret elevate</function>
		<mouseaxis>y</mouseaxis>
		<keyabsolute value="0.00" onrelease="50.00">
			<key>left shift</key>
			<key>s</key>
		</keyabsolute>
		<keyabsolute value="40.00" onrelease="50.00" index="4">
			<key>s</key>
		</keyabsolute>
		<keyabsolute value="60.00" onrelease="50.00" index="6">
			<key>w</key>
		</keyabsolute>
		<keyabsolute value="100.00" onrelease="50.00" index="10">
			<key>left shift</key>
			<key>w</key>
		</keyabsolute>
	</control>	
	<control>
		<function>mixture off</function>
		<combo>
			<key>left shift</key>
			<key>m</key>
		</combo>
	</control>
	<control>
		<function>mixture lean</function>
		<combo>
			<key>left control</key>
			<key>m</key>
		</combo>
	</control>
	<control>
		<function>mixture rich</function>
		<combo>
			<key>right control</key>
			<key>m</key>
		</combo>
	</control>
	<control>
		<function>ll switch</function>
		<combo>
			<key>left control</key>
			<key>n</key>
		</combo>
	</control>
	<control>
		<function>cock next fuel tank</function>
		<key>u</key>
	</control>
	<control>
		<function>cowl flaps</function>
	</control>
	<control>
		<function>panel light</function>
		<combo>
			<key>left shift</key>
			<key>n</key>
		</combo>
	</control>
	<control>
		<function>canopy control</function>
		<key>o</key>
	</control>
	<control>
		<function>deploy dive brakes</function>
		<key>c</key>
	</control>
	<control>
		<function>flap execute</function>
	</control>
	<control>
		<function>engine start/stop</function>
		<key>e</key>
	</control>
	<control>
		<function>toggle tail lock</function>
		<key>/</key>
	</control>
	<control>
		<function>toggle bomb bay door</function>
		<key>b</key>
	</control>
	<control>
		<function>deploy weapon</function>
		<key>z</key>
	</control>
	<control>
		<function>stuka siren</function>
		<key>right shift</key>
	</control>
	<control>
		<function>adjust prop up</function>
		<key>'</key>
	</control>
	<control>
		<function>adjust prop down</function>
		<key>;</key>
	</control>
	<control>
		<function>toggle wep</function>
		<key>f8</key>
	</control>
	<control>
		<function>cycle ammo</function>
		<key>backspace</key>
	</control>
	<control>
		<function>use primary weapon</function>
		<mousebutton>1</mousebutton>
	</control>
	<control>
		<function>use secondary weapon</function>
		<mousebutton>2</mousebutton>
	</control>		
	<control>
		<function>roll</function>
		<keyabsolute value="0.00" onrelease="50.00">
			<key>left shift</key>
			<key>a</key>
		</keyabsolute>
		<keyabsolute value="30.00" onrelease="50.00" index="3">
			<key>a</key>
		</keyabsolute>
		<keyabsolute value="70.00" onrelease="50.00" index="7">
			<key>d</key>
		</keyabsolute>
		<keyabsolute value="100.00" onrelease="50.00" index="10">
			<key>left shift</key>
			<key>d</key>
		</keyabsolute>
	</control>
	<control>
		<function>pitch</function>
		<keyabsolute value="0.00" onrelease="50.00">
			<key>left shift</key>
			<key>s</key>
		</keyabsolute>
		<keyabsolute value="30.00" onrelease="50.00" index="3">
			<key>s</key>
		</keyabsolute>
		<keyabsolute value="70.00" onrelease="50.00" index="7">
			<key>w</key>
		</keyabsolute>
		<keyabsolute value="100.00" onrelease="50.00" index="10">
			<key>left shift</key>
			<key>w</key>
		</keyabsolute>
	</control>
	<control>
		<function>yaw</function>
		<keydelta value="3.00" per="sec" index="4">
			<key>right arrow</key>
		</keydelta>
		<keydelta value="-3.00" per="sec" index="5">
			<key>left arrow</key>
		</keydelta>
		<keyabsolute value="50.00" onrelease="50.00" index="7">
			<key>down arrow</key>
		</keyabsolute>
	</control>
	<control>
		<function>throttle</function>
		<keydelta value="5.00" per="keypress" index="2">
			<key>f</key>
		</keydelta>
		<keydelta value="-5.00" per="keypress" index="3">
			<key>v</key>
		</keydelta>
		<keydelta value="10.00" per="keypress" index="4">
			<mousebutton>wheelup</mousebutton>
		</keydelta>
		<keydelta value="-10.00" per="keypress" index="5">
			<mousebutton>wheeldown</mousebutton>
		</keydelta>
	</control>
	<control>
		<function>position 1</function>
		<key>1</key>
	</control>			
	<control>
		<function>position 2</function>
		<key>2</key>
	</control>	
	<control>
		<function>position 3</function>
		<key>3</key>
	</control>	
	<control>
		<function>position 4</function>
		<key>4</key>
	</control>	
	<control>
		<function>position 5</function>
		<key>5</key>
	</control>	
	<control>
		<function>position 6</function>
		<key>6</key>
	</control>	
	<control>
		<function>position 7</function>
		<key>7</key>
	</control>	
	<control>
		<function>position 8</function>
		<key>8</key>
	</control>	
	<control>
		<function>position 9</function>
		<key>9</key>
	</control>	
	<control>
		<function>position 10</function>
		<key>0</key>
	</control>
	<control>
		<function>left brake</function>
		<keyabsolute value="100" onrelease="0" index="10">
			<key>z</key>
		</keyabsolute>
	</control>
	<control>
		<function>right brake</function>
		<keyabsolute value="100" onrelease="0" index="10">
			<key>x</key>
		</keyabsolute>
	</control>
	<control>
		<function>flap control</function>
		<keyabsolute value="100" index="10">
			<key>delete</key>
		</keyabsolute>
		<keyabsolute value="0" index="0">
			<key>insert</key>
		</keyabsolute>
	</control>
	<control>
		<function>elevator trim</function>
		<keydelta value="1" per="keypress" index="0">
			<key>k</key>
		</keydelta>
		<keydelta value="-1" per="keypress" index="1">
			<key>i</key>
		</keydelta>
	</control>
	<control>
		<function>aileron trim</function>
		<keydelta value="1" per="keypress" index="0">
			<key>.</key>
		</keydelta>
		<keydelta value="-1" per="keypress" index="1">
			<key>,</key>
		</keydelta>
	</control>
	<control>
		<function>rudder trim</function>
		<keydelta value="1" per="keypress" index="0">
			<key>l</key>
		</keydelta>	
		<keydelta value="-1" per="keypress" index="1">
			<key>j</key>
		</keydelta>
	</control>
	<control function="jettison ordnance">
	       <combo>
               <key>left control</key>
               <key>j</key>
               </combo>
       </control>	
	<control function="autopilot">
		<combo>
		<key>left control</key>
		<key>a</key>
		</combo>
	</control>
</controlset>