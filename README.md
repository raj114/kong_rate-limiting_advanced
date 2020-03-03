# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

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
	

	

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact