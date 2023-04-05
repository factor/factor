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
		<joyaxis stick="1">x</joyaxis>
	</control>	
	<control>
		<function>turret elevate</function>
		<joyaxis stick="1" invert="1">y</joyaxis>
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
		<joybutton stick="1">1</joybutton>
	</control>
	<control>
		<function>use secondary weapon</function>
		<joybutton stick="1">2</joybutton>
	</control>		
	<control>
		<function>roll</function>
		<joyaxis stick="1">x</joyaxis>
	</control>
	<control>
		<function>pitch</function>
		<joyaxis stick="1">y</joyaxis>
	</control>
	<control>
		<function>yaw</function>
		<joyaxis stick="1">rz</joyaxis>
	</control>
	<control>
		<function>throttle</function>
		<joyaxis stick="1">z</joyaxis>
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