# cf-app-events-logger
Logs data from the CF /v2/events API

# Pre-steps
  
    bundle package --all

Make sure your application is pushed into a space that has a security group that allows it to talk to the cf uaa and the cf api


    [
	{
		"destination": "10.244.0.34/32",
		"ports": "80",
		"protocol": "tcp"
	},
	{
		"destination": "10.244.0.34/32",
		"ports": "443",
		"protocol": "tcp"
	}
   ]

Make necessary changes to the manifest.yml to reflect your environment.

# Push

```
cf target -o system -s elk-for-pcf
cf push --no-start
cf set-env cf-app-events-logger CF_PASSWORD <admin_user_password>
cf set-env cf-app-events-logger CF_API https://api.system.<your.cf.domain>
cf set-health-check cf-app-events-logger none #If deploying to Diego
cf start cf-app-events-logger
```
