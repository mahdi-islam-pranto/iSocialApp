class ApiUrls {
  static const String baseUrl =
      'https://omni.ihelpbd.com/ihelpbd_social_development/api/v1';

  // All ticket list
  static String ticketList = '$baseUrl/ticket_list.php';
  // All ticket conversionList
  static String conversationList = '$baseUrl/ticket_show.php';
  // Ticket reply
  static String ticketReplay = '$baseUrl/ticket_reply.php';
  // Ticket attahmenturl
  static String attachmentReplyUrl = '$baseUrl/facebook_attachment_send.php';
  // Logout
  static String logoutUrl = '$baseUrl/logout.php';
  // Ticket all agent list
  static String agentListUrl = '$baseUrl/agent_list.php';
  // Ticket transfer
  static String transferTicketUrl =
      '$baseUrl/transfer_ticket.php'; // This is a placeholder, replace with actual endpoint

  // whatsApp api url
  // All whatsapp List
  static String waTicketList = '$baseUrl/wa_ticket_list.php';
  // All Ticket conversion list
  static String waTicketConverstionList = '$baseUrl/wa_ticket_show.php';
  // New Ticket list
  static String waNewTicket = '$baseUrl/wa_ticket_list_new.php';
  // Ticket reply list
  static String waTicketreply = '$baseUrl/wa_ticket_reply.php';
  // Ticket attachment reply sand
  static String waAttachmentReply = '$baseUrl/whatsapp_attachment_send.php';

  static const String whatsAppBaseUrl =
      'https://omni.ihelpbd.com/ihelpbd_social_development/';

  // watsapp Ticket transfer
  static String waTransferTicketUrl = '$baseUrl/wa_transfer_ticket.php';
}
