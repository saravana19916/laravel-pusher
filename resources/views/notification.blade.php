<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title></title>
	<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
	<script src="//js.pusher.com/3.1/pusher.min.js"></script>
</head>
<body>
	<h2>Notification</h2>

	<script>
		var pusher = new Pusher('b8bf0a83fce4dc961449', {
	        cluster: 'ap2',
	        encrypted: true
	      });

	      // Subscribe to the channel we specified in our Laravel Event
	      var channel = pusher.subscribe('send-notification');

	      // Bind a function to a Event (the full Laravel class)
	      channel.bind('App\\Events\\SendNotification', function(data) {
	      	console.log("data", data);
	      });
	</script>
</body>
</html>