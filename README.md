# README #

This README would normally document whatever steps are necessary to get your application up and running.

### How do I get set up? ###

* Summary of set up

* Database configuration
	
	* Add database configuration in your kong.conf file assume that you used postgresql data base then add following entries in kong.conf file
		
			pg_user = your_user                  # Postgres user.
		
			pg_password = your_password          # Postgres user's password.
		
			pg_database = your_databaseName      # The database name to connect to.

* How to run Kong use below commands
	* How to start kong :-
	 		
			sudo kong start -c /path/to/kong.conf
	 
	* How to stop kong :-
	 	
			sudo kong stop
	 
	* How to reload kong :-
	 	
			sudo kong reload
	 
	* How to run kong migrations :-
	 	
			kong migrations bootstrap
	 
	* How to reset kong migrations :-
	 	
			kong migrations reset
	 
	* How to up kong migrations :-
	 	
			kong migrations up

* How Deploy our custom plugin in Kong
	
	* First go to that folder where is your pluging code like cd /your_path_of_plugin_folder
	
	* we'll generate a template for the rockspec using luarocks. luarocks is the package manager for the Lua programming lanague. 
	  It comes with Kong. Packages and libraries managed by luarocks are referred to as "rocks" in Lua. In this case, our rockspec 
	  file is a document detailing what our plugin is, including where the repository is located, and what dependencies the plugin needs to run. 
	  Run the following commands to generate a template file 
			
			luarocks write_rockspec
	
	* To make the luarocks file run the below command :-
			
			sudo luarocks make
	
	* Adding our custom_plugin in kong
		* To run our plugin, we first need to inform Kong of its presence using the kong.conf file that we created earlier. Open it up, search for plugins, and add our plugin. 
		  The line should look like this:
			
				plugins = bundled, kong-plugin-header-echo
		
		* Then save and exit the file. Finally, cd to the root directory of your plugin and run:
				
				kong start -c /path/to/your/kong.conf
			
		* To verify that Kong knows about your plugin, execute the following command:
				
				curl http://localhost:8001/ | python -mjson.tool
		*You should see your plugin in the plugins.available_on_server array!
			
* If your plugin is already deploy in kong and you added new change then how to deploy without reset the database :-
	
	* First go to that folder where is your pluging code like cd /your_path_of_plugin_folder
	
	* Run the below command :-
		
			rm -rf kong-plugin-rate-limit-dev-1.rockspec 
		
			luarocks write_rockspec
		
			sudo luarocks make
		
			sudo kong reload
	


* How the plugin actual works :-


	* Rate limiting plugin basically used for to apply restriction on API calls for controling the API Access.
   
   	* Now how it works in that case firstly we create a consumer when we create a consumer we send tag in request body the tag like it is Tenant or it is APP_CLIENT 
	  there are multiple app clients.
   
   	* After creating consumers we know the all consumer ids and using tag we also know the who is Tenant and who is APP_CLIENT so we used that consumer id as a parent consumer id in our 
	  rate-limiting plugin when we enabled our plugin on that consumer.

	
			* let assume one example let say we create three consumers 
		
					Tenant (tag) - 3205c031-c37e-4a64-9163-5e2ab78b482f (consumer_id) - 5 (rate-limit in hour) 
			
					App_client_1 (tag) - 2661129c-b596-460c-9a75-bc0f8b1de795 (consumer_id) - 3 (rate-limit in hour) 
			
					App_client_2 (tag) - 7768beb7-8048-4ed4-aafb-053d51960659 (consumer_id) -2 (rate-limit in hour) 

			* we can identify the consumers using tags.

			* when we apply rate-limiting plugin on App_client_1 and App_client_2 we can pass the Tenant consumer id as a parent consumer id in the requst body for enable the plugin,
	  	  	  if and only if  you want to apply hirarachy between tenant and App_client.

			* when we hit the api for App_client_1 that time our plugin update the value for that consumer id also and if the parent consumer id is present in there config then it also update for same . 
	  	  	  It balanced the all hirarachy order. and if the rate limit is over it will give the response like "API rate limit exceeded".

* Other community or team contact

	# Kanaka Software 
		* 302 Indira Icon, Right Bhusari Colony, Paud Road, Pune - 411038 INDIA.
		* Email :- info@kanakasoftware.com