class ApiUrls {
  static const String baseUrl =
      'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1';

  static String ticketList = '$baseUrl/ticket_list.php';
  static String conversationList = '$baseUrl/ticket_show.php';
  static String ticketReplay = '$baseUrl/ticket_reply.php';
  static String attachmentReplyUrl = '$baseUrl/facebook_attachment_send.php';
  static String logoutUrl = '$baseUrl/logout.php';
  static String agentListUrl = '$baseUrl/agent_list.php';
  static String transferTicketUrl =
      '$baseUrl/transfer_ticket.php'; // This is a placeholder, replace with actual endpoint
}
