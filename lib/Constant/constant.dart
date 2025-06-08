const String addresse = "http://192.168.43.169:8080/";
const String websocket_url = "ws://192.168.43.169:8080/ws";

const String defaultProfilePic = 'assets/images/default_profile_picture.png';
const String defaultCoverPic = 'assets/images/default_cover_picture.png';
const String signup_endpoint = "${addresse}user/registerUser";
const String login_endpoint = "${addresse}auth/login";
const String allUsersendpoint = "${addresse}user/all";
const String sharePostendpoint = "${addresse}post/statue";
const String sendFriendRequestEndpoint = "${addresse}api/friends/sendRequest";
const String getSentFriendRequestsEndpoint = "${addresse}api/friends/sent";
const String getReceivedFriendRequestsEndpoint = "${addresse}api/friends/received";
const String statusFriendRequestEndpoint = "${addresse}api/friends/status";
const String FriendRequestReceved = "${addresse}api/friends/received/";
const String FetchUserinformation = "${addresse}user/details/";
const String FriendRequestAccept = "${addresse}api/friends/accept/";
const String FriendRequestReject = "${addresse}api/friends/reject/";
const String FetchUserPosts = "${addresse}post/statueUser/";
const String FetchUserFriends = "${addresse}api/friends/";
const String FetchFriendPostes = "${addresse}api/friends/friendsPosts/";
const String FetchVideos = "${addresse}post/videos";

//Comment
const String FetchPostComments = "${addresse}comments/getCommentsByPostId/";
const String addcomment = "${addresse}comments/add";

//Likes
const String LikePost = "${addresse}Like/like";
const String getAllLikesBypost = "${addresse}Like/getLikesbypost";

//Notification
const String getAllNotification = "${addresse}Notification/user";

//Messages
const String websocket_send_message = "/app/chat.sendMessage"; // Pour envoyer un message
const String websocket_receive_message_prefix = "/user/";      // Préfixe pour s'abonner
const String websocket_receive_message_suffix = "/queue/messages"; // Suffixe

// REST endpoints liés aux messages
const String getAllMessagesEndpoint = "${addresse}api/messages/"; // + {userId}/{friendId}
const String getLastMessageEndpoint = "${addresse}api/messages/last/"; // + {userId}/{friendId}