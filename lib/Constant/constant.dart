const String addresse = "http://192.168.1.14:8080/";
const String defaultProfilePic = 'assets/images/default_profile_picture.png';
const String defaultCoverPic = 'assets/images/default_cover_picture.png';
const String signup_endpoint = "${addresse}user/registerUser";
const String login_endpoint = "${addresse}auth/login";
const String allUsersendpoint = "${addresse}user/all" ;
const String sharePostendpoint="${addresse}post/statue";
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
const String FetchVideos = "${addresse}/post/videos/";
const String websocket_url = "ws://192.168.1.14:8080/ws/websocket";
const String sendMessageEndpoint = "${addresse}chat/sendMessage"; // Pour envoyer un message
const String getLastMessagesEndpoint = "${addresse}api/messages/last"; // Pour obtenir les derniers messages
const String getMessagesEndpoint = "${addresse}api/messages"; // Pour obtenir tous les messages d'une conversation
const String markMessageAsReadEndpoint = "${addresse}api/messages/markAsRead"; // Pour marquer un message comme lu
const String deleteMessageEndpoint = "${addresse}api/messages/delete"; // Pour supprimer un message
const String getUserChatsEndpoint = "${addresse}api/messages/chats"; // Pour obtenir la liste des conversations

