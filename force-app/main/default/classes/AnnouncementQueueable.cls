/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
**/
public class AnnouncementQueueable implements Queueable{

    public List<ConnectApi.AnnouncementInput> toPost;

    //constructor
    public AnnouncementQueueable(List<ConnectApi.AnnouncementInput> annouceList){
        toPost = annouceList;
    }


    /**
     * @name postAnnouncements
     * @description This method is provided for you to facilitate the Super Badge
    **/
    public static void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
        while ( announcements.size() > 0 ){
            if ( Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest() ){
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                break;
            }
        }
        if ( announcements.size() > 0 && !test.isRunningTest() ){
            AnnouncementQueueable q = new AnnouncementQueueable(announcements);
            //do not need anymore as we implemented queueable so need to enqueue...
            //q.toPost = announcements;
            System.enqueueJob(q);
        }
    }

    //execute
    public void execute(QueueableContext context){
        PostAnnouncements(toPost);
    }
}