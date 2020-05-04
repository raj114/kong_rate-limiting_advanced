<<<<<<< HEAD
# README #

This README would normally document whatever steps are necessary to get your application up and running.

### How do I get set up? ###

* Prerequisite -  PostgreSQL and Kong are installed in your system

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
	
	* Generate a template for the rockspec using luarocks. luarocks is the package manager for the Lua programming lanague. 
	  It comes with Kong. Packages and libraries managed by luarocks are referred to as "rocks" in Lua. In this case, the rockspec 
	  file is a document detailing what our plugin is, including where the repository is located, and what dependencies the plugin needs to run. 
	  Run the following commands to generate a template file 
			
			luarocks write_rockspec
	
	* To make the luarocks file run the below command :-
			
			sudo luarocks make
	
	* Adding custom rate limiting plugin in Kong
		* Append the custom plugin name in the kong.conf file as shown below
			
				plugins = bundled, kong-plugin-header-echo
		
		* Start Kong
				
				kong start -c /path/to/your/kong.conf
			
		* To verify if the plugin is installed properly, execute the following command:
				
				curl http://localhost:8001/ | python -mjson.tool
		*You should see your plugin in the plugins.available_on_server array!
			
* If your plugin is already deployed in Kong and you added new change then how to deploy without reset the database :-
	
	* Go to that folder where is your pluging code like cd /your_path_of_plugin_folder
	
	* Run the below command :-
		
			rm -rf kong-plugin-rate-limit-dev-1.rockspec 
		
			luarocks write_rockspec
		
			sudo luarocks make
		
			sudo kong reload
	


* How the plugin works :-


	* Custom Rate limiting plugin is for controling the API access hierarchical fashion. You can establish the parent-child relationship while defining the consumers. You can achive limit at all client consumer level and also indivdual client level by grouping all clients under one tenant.
	
   
   	* While creating a consumer send tag in request body to denote the consumer as Tenant or Client etc 
	  
   
   	* Set Tenant consumer id as a parent consumer id in the 
	  Custom Rate limiting plugin at the time of enabling the plugin for Client consumer.

	
			* Let's create three consumers to illustrate an example 
		
					Tenant (tag) - 3205c031-c37e-4a64-9163-5e2ab78b482f (consumer_id) - 5 (rate-limit in hour) 
			
					App_client_1 (tag) - 2661129c-b596-460c-9a75-bc0f8b1de795 (consumer_id) - 3 (rate-limit in hour) 
			
					App_client_2 (tag) - 7768beb7-8048-4ed4-aafb-053d51960659 (consumer_id) -2 (rate-limit in hour) 

			* We can identify the consumers using tags.

			* While enabling the rate-limiting plugin for App_client_1 and App_client_2, pass the Tenant consumer id as a parent consumer id in the request body.
	  	  	  This will establish the parent-child hirarachy between Tenant and App_client.

			* When we access the API for App_client_1, the plugin will update the value for the consumer and also for the parent consumer id if applicable. 
	  	  	  It maintains the access history for all the consumers in the hirarachy. It will give the response like "API rate limit exceeded" if consumer exhausts it's limit at individual level or parent level.

* Other community or team contact

	# Kanaka Software 
		* Address :- 302 Indira Icon, Right Bhusari Colony, Paud Road, Pune - 411038 INDIA.
		* Email :- info@kanakasoftware.com
=======
# kong_rate-limiting_advanced
>>>>>>> 5a24a0be40de17fa1b6c586030fab5ae2802e554
