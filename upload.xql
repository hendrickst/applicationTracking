xquery version "3.1";

(: Import eXist-db utility modules for UUIDs and DB storage :)
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace util="http://exist-db.org/xquery/util";

(: 1. Define target collection :)
declare variable $targetCollection := "/db/jobs/applications/";

(: 2. Your Parent XML dataset (Simplified for this run) :)
declare variable $bulkJobs := 
<jobs>
    <job id="">
        <company>Lakeshore College</company>
        <url/>
        <title>Information Technology Manager</title>
        <dates applied="2025-11-25" rejected="2025-12-01"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home/requisition/69145?c=kohler&amp;sq=req69145&amp;lang=en-US</url>
        <title>Sr. Training Specialist</title>
        <dates applied="2025-12-02" rejected="2025-12-03"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;country=us&amp;state=wi&amp;city=kohler&amp;lang=en-US#/requisition/69324</url>
        <title>Sr. Manager, Salesforce</title>
        <dates applied="2025-12-02" rejected="2025-12-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;country=us&amp;state=wi&amp;city=kohler&amp;lang=en-US#/requisition/69316</url>
        <title>Media Optimization Analyst</title>
        <dates applied="2025-12-02" rejected="2026-01-14"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req68361&amp;country=us&amp;state=wi&amp;city=kohler&amp;lang=en-US#/requisition/68361</url>
        <title>Digital Product Manager, Workday, HR</title>
        <dates applied="2025-12-03" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Johnsonville</company>
        <url>https://careers.johnsonville.com/Johnsonville/job/Sheboygan-Falls-Director-of-Enterprise-Master-Data-WI-53085/1346644900/</url>
        <title>Director of Enterprise Master Data</title>
        <dates applied="2025-12-03" rejected="2025-12-04"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req69352&amp;country=us&amp;state=wi&amp;city=kohler&amp;date=WithinSevenDays&amp;lang=en-US#/requisition/69352</url>
        <title>Sr. Learning &amp; Development Specialist</title>
        <dates applied="2025-12-04" rejected="2025-12-10"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req69225&amp;country=us&amp;state=wi&amp;city=kohler&amp;lang=en-US#/requisition/69225</url>
        <title>Digital Product Manager, ServiceNow, HR</title>
        <dates applied="2025-12-03" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req68285&amp;country=us&amp;state=wi&amp;city=kohler&amp;lang=en-US#/requisition/68285</url>
        <title>Sr. Category Leader, IT</title>
        <dates applied="2025-12-04" rejected="2025-12-10"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22629859/manager-it-asset-management-remote/</url>
        <title>Manager IT Asset Management</title>
        <dates applied="2025-12-11" rejected="2026-01-21"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req69505&amp;country=us&amp;state=wi&amp;city=kohler&amp;date=WithinSevenDays&amp;lang=en-US#/requisition/69505</url>
        <title>Data Scientist</title>
        <dates applied="2025-12-11" rejected="2026-01-08"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;sq=req69233&amp;country=us&amp;state=wi&amp;city=kohler&amp;date=WithinSevenDays&amp;lang=en-US#/requisition/69233</url>
        <title>Technical Recruiter</title>
        <dates applied="2025-12-11" rejected="2025-12-15"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22712539/epic-applications-analyst-bugsy-infection-prevention-remote/</url>
        <title>EPIC Applications Analyst- Bugsy/ Infection Prevention</title>
        <dates applied="2025-12-11" rejected="2025-12-15"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22719129/it-epic-solutions-developer-remote/</url>
        <title>IT Epic Solutions Developer</title>
        <dates applied="2025-12-11" rejected="2026-01-01"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22720448/sr-erp-mergers-and-acquisitions-coordinator-remote/</url>
        <title>Sr ERP Mergers and Acquisitions Coordinator</title>
        <dates applied="2025-12-11" rejected="2025-12-15"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Habitat for Humanity</company>
        <url>https://sjobs.brassring.com/TGnewUI/Search/home/HomeWithPreLoad?PageType=JobDetails&amp;partnerid=26053&amp;siteid=5396&amp;jobid=837582#jobDetails=837582_5396</url>
        <title>Senior Manager, Content and Knowledge Management</title>
        <dates applied="2025-12-15" rejected="2026-02-17"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Curt G. Joa</company>
        <url>https://jobs.dayforcehcm.com/en-US/joa/CANDIDATEPORTAL/jobs/3264</url>
        <title>Technical Services Manager</title>
        <dates applied="2025-12-16" rejected="2026-01-21"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Sargento</company>
        <url>https://careers.sargento.com/us/en/job/SFINUSITSCR003928EXTERNALENUS/IT-Scrum-Project-Manager</url>
        <title>IT Scrum-Project Manager (ITSCR003928)</title>
        <dates applied="2026-01-14" rejected="2026-01-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Rehlko</company>
        <url>https://rehlko.wd12.myworkdayjobs.com/en-US/Reh/job/Warranty-Specialist_R02626</url>
        <title>Warranty Specialist</title>
        <dates applied="2026-01-14" rejected="2026-01-18"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>American Orthodontics</company>
        <url>https://recruiting.ultipro.com/AME1064AMEOR/JobBoard/b76035b2-2f9c-49c0-a6e1-16bf401e522c/OpportunityDetail?opportunityId=dc7e0ec7-7503-4015-80a0-85b0211c153f</url>
        <title>Endpoint Administrator</title>
        <dates applied="2026-01-20" rejected="2026-02-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-01-26" type="Other">Phone interview</note>
            <note date="2026-02-03" type="Other">In-person interview</note>
            <note date="2026-02-10" type="Other">Send follow-up email</note>
            <note date="2026-02-11" type="Other">Received reply that they had filled the position. I did reply asking about asset management position that had been mentioned during the interview.</note>
            <note date="2026-02-19" type="Other">Official rejection email.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>US Foods</company>
        <url>https://careers.usfoods.com/us/en/job/R274900/IT-Delivery-Consultant-Director-level-Remote</url>
        <title>IT Delivery Consultant (Director Level) Remote</title>
        <dates applied="2026-01-20" rejected="2026-02-05"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>US Foods</company>
        <url>https://careers.usfoods.com/us/en/job/R274116/Sr-IT-Strategy-Analyst-remote</url>
        <title>Sr IT Strategy Analyst</title>
        <dates applied="2026-01-20" rejected="2026-01-21"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Tri Soft IT Solutions</company>
        <url>https://www.linkedin.com/posts/neha-kakara-42412b291_we-are-hiring-product-owner-scrum-activity-7414316615757934592-BSg8/</url>
        <title>Product Owner / Scrum Master</title>
        <dates applied="2026-01-20" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Johnsonville</company>
        <url>https://careers.johnsonville.com/Johnsonville/job/Sheboygan-Falls-Corporate-Communications-Manager-Operations-WI-53085/1357062600/</url>
        <title>Corporate Communications Manager - Operations</title>
        <dates applied="2026-01-20" rejected="2026-01-31"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Acuity</company>
        <url>https://recruiting2.ultipro.com/HER1001ACFIN/JobBoard/ab33798a-3521-417b-8db8-a8e435c475fa/OpportunityDetail?opportunityId=94b1b82e-ddbd-43af-9922-f132db6ea178</url>
        <title>Data Scientist - Strategic Analytics</title>
        <dates applied="2026-01-20" rejected="2026-02-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Newbook</company>
        <url>https://newbook.com/careers/</url>
        <title>Systems Analyst – Structured Content QA, Publishing &amp; Deployment</title>
        <dates applied="2026-01-22" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Tandym Group</company>
        <url>https://www.linkedin.com/jobs/view/4360974288/?refId=953d5b19-e9fe-454b-9e3b-451fe12079fd&amp;trackingId=jLgeYfo4QZSu%2BiUGB8uuRw%3D%3D</url>
        <title>Scrum Master</title>
        <dates applied="2026-01-22" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>TransPerfect</company>
        <url>https://www.linkedin.com/jobs/view/4323534796/?refId=4829f5e0-1628-47a4-af13-7f81c77e2461&amp;trk=flagship3_job_home_savedjobs</url>
        <title>Content Solutions Engineer</title>
        <dates applied="2026-01-22" rejected="2026-02-04"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>.monks</company>
        <url>https://www.monks.com/careers/chicago/software-delivery-tech/agile-specialist-remote-us?gh_src=a9b949034us</url>
        <title>Agile Specialist (Remote in US)</title>
        <dates applied="2026-01-22" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Motion Recruitment</company>
        <url>linkedin.com/comm/jobs/view/4358765525/?trackingId=5LvipAo0Sp6DtpIrc7or3Q%3D%3D&amp;refId=J%2F6FT9UtQC%2B%2BpZIwgzvCTw%3D%3D&amp;lipi=urn%3Ali%3Apage%3Aemail_email_application_confirmation_with_nba_01%3ByNdBSY%2BgT4O1xPQm5PY%2BXg%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=0LTEKO4-Qx-Y41&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body-null-px2gi~mkulesqw~7l-null-null&amp;eid=px2gi-mkulesqw-7l&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVjNGYxZGVlYjM4ZGNlZDQ0NDkxYWE4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjODliZDg2NGJkN2VmYzI3NGNlMDE5M2Y0OWM5ZDc5MWJjNjcxOWMxMGE4Y2QwZWIyLDEsMQ%3D%3D</url>
        <title>Agile Product Owner / Business Analyst</title>
        <dates applied="2026-01-25" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Undisclosed</company>
        <url>https://www.linkedin.com/jobs/view/4364251545/?trackingId=1XwC1xTfSuWjqn6EmVg5zg%3D%3D&amp;refId=y8l6wi%2F8SO67pvfCvZFjfQ%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=3YIGwsozyy-Y41&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body-null-px2gi~mkuq0971~ol-null-null&amp;eid=px2gi-mkuq0971-ol&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVjNGYxYWU3YjA4NmNjZDQ0MDlkYTY4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjYWNhZjk2NGJiNWUwODA1OTFjZGRjMjU0NDBlZjI2OGUyMmRmMzQyNGYwMzU1NThjLDEsMQ%3D%3D</url>
        <title>Business Analyst</title>
        <dates applied="2026-01-25" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Mango</company>
        <url>https://www.linkedin.com/jobs/view/4363394243/?trackingId=1rBFBbaISTypnoxQO3O%2BOQ%3D%3D&amp;refId=T0VrI%2B6eT%2Barq%2FbaTNe9nA%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=1qa6R6tiWB-Y41&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-job_posting&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-job_posting-null-px2gi~mkuq4icy~uf-null-null&amp;eid=px2gi-mkuq4icy-uf&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVjNGYxYWU3YjE4ZWNjZDI0NzljYWE4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjOWY4Y2I4NjFlNWMwODU0ZTU2NjUzZmM0YzY2MmMwNjg2YmNlOTRmNzIzNDMzODQ1LDEsMQ%3D%3D</url>
        <title>Technical Project Manager</title>
        <dates applied="2026-01-26" rejected="2026-01-28"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Motion Recruitment</company>
        <url>https://www.linkedin.com/jobs/view/4358587552/?trackingId=m6fFPx74RGyF91UiYguJ%2BQ%3D%3D&amp;refId=us9WgjTVSNSf6Z94a1qiMQ%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=0JvwqWE-Hm-Y41&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body-null-px2gi~mkupqm6i~xo-null-null&amp;eid=px2gi-mkupqm6i-xo&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVjNGYxYWU3YmM4ZmM4ZDQ0MjljYTk4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjZGM4YmIwN2JlN2U4ZmE3YzlhZDlhNmQyYjk1MTY0M2Y3YmE0YzM4M2M1YWZjZjU4LDEsMQ%3D%3D</url>
        <title>Scrum Master</title>
        <dates applied="2026-01-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;country=us&amp;state=wi&amp;city=kohler&amp;date=WithinFifteenDays&amp;lang=en-US#/requisition/69780</url>
        <title>Sr. Product Analyst (Scot Warady)</title>
        <dates applied="2026-01-26" rejected="2026-02-02"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-01-29" type="Other">Phone interview</note>
            <note date="2026-02-02" type="Other">Rejected do to lacking undergraduat degree</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Habitat for Humanity</company>
        <url>https://sjobs.brassring.com/TGnewUI/Search/home/HomeWithPreLoad?PageType=JobDetails&amp;partnerid=26053&amp;siteid=5396&amp;jobid=837582#jobDetails=836297_5396</url>
        <title>Release Train Engineer</title>
        <dates applied="2026-01-26" rejected="2026-02-03"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Johnsonville</company>
        <url>https://careers.johnsonville.com/Johnsonville/job/Sheboygan-Falls-Business-Process-Analyst-WI-53085/1357890800/</url>
        <title>Business Process Analyst</title>
        <dates applied="2026-01-26" rejected="2026-01-30"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Ryan Specialty</company>
        <url>https://ryansg.wd5.myworkdayjobs.com/Ryan_Specialty_Career_Site/job/Chicago---Illinois---Wacker/Enterprise-Jira-Application-Owner_JR26-3915-1?source=LinkedIn</url>
        <title>Enterprise Jira Aplication Owner</title>
        <dates applied="2026-01-26" rejected="2026-01-26"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>MedPro</company>
        <url>https://medprou.csod.com/ux/ats/careersite/5/home/requisition/1956?c=medprou&amp;source=LinkedIn</url>
        <title>Senior Atlassian Administrator</title>
        <dates applied="2026-01-26" rejected="2026-03-24"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Mapbox</company>
        <url>https://jobs.ashbyhq.com/mapbox/2b645f5f-b7cd-44c5-b11c-48e9ca905e26?src=LinkedIn</url>
        <title>Senior Atlassian Administrator</title>
        <dates applied="2026-01-26" rejected="2026-01-27"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Acuity</company>
        <url>https://recruiting2.ultipro.com/HER1001ACFIN/JobBoard/ab33798a-3521-417b-8db8-a8e435c475fa/OpportunityApply?opportunityId=213ade2b-6592-4033-9e84-f772c9be7171</url>
        <title>Systems Engineer - Data</title>
        <dates applied="2026-01-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Acuity</company>
        <url>https://recruiting2.ultipro.com/HER1001ACFIN/JobBoard/ab33798a-3521-417b-8db8-a8e435c475fa/OpportunityDetail?opportunityId=1dc30b52-caca-429c-9870-472d0afa529d</url>
        <title>Systems Engineer - Database Administration</title>
        <dates applied="2026-01-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Acuity</company>
        <url>https://recruiting2.ultipro.com/HER1001ACFIN/JobBoard/ab33798a-3521-417b-8db8-a8e435c475fa/OpportunityDetail?opportunityId=3272b36a-1a0c-423d-8e99-406a4f1b6660</url>
        <title>Technical Support Analyst</title>
        <dates applied="2026-01-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Department of Corrections</company>
        <url>https://wj.wi.gov/psc/wisjobs/CAREERS/HRMS/c/HRS_HRAM_FL.HRS_CG_SEARCH_FL.GBL?Page=HRS_APP_JBPST_FL&amp;Action=U&amp;FOCUS=Applicant&amp;SiteId=1&amp;PostingSeq=1&amp;JobOpeningId=19812&amp;</url>
        <title>IT Project Manager</title>
        <dates applied="2026-01-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-02-12" type="Other">Received notification that I am eligible for further consideration. No action needed but I may receive another email soon with the next step of the selection process.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Piggly Wiggly</company>
        <url>https://careers.cswg.com/sheboygan-wi/mgr-retail-systems-operations/F0D323ACFF0347168C06BBF441CA8ABA/job/</url>
        <title>Mgr. Retail Systems Operations</title>
        <dates applied="2026-01-28" rejected="2026-01-30"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Human Interest</company>
        <url>https://job-boards.greenhouse.io/humaninterest/jobs/7492113?gh_src=dea5e79a1us</url>
        <title>Sr Jira &amp; Confluence Administrator</title>
        <dates applied="2026-01-28" rejected="2026-01-31"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Snowrelic In</company>
        <url>https://www.linkedin.com/jobs/view/4343167095/</url>
        <title>DITA Architect (W2)</title>
        <dates applied="2026-01-28" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Sargento (April Perez)</company>
        <url/>
        <title>Enterprise Data</title>
        <dates applied="2026-01-28" rejected="2026-01-29"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-01-26" type="Other">Phone interview</note>
            <note date="2026-01-29" type="Other">Rejected due to desired experience level</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Newbook</company>
        <url>https://drive.google.com/file/d/1YQ_vj8Hq3Bo_XLsO1A_yB_Io52TnEfxa/view?usp=drive_link</url>
        <title>Systems Analyst</title>
        <dates applied="2026-01-22" rejected="2026-02-06"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-02-06" type="Other">Phone interview</note>
            <note date="2026-02-06" type="Other">I declined due to pay. 90k Canadian converts to just under 67k and does not include insurance. Would end up working for less than 30k. I did leave door open for smaller contracts</note>
            <note date="2026-02-09" type="Other">They reached out for another interview. I accepted.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>H.W. Kaufman Group</company>
        <url>https://www.linkedin.com/comm/jobs/view/4370546733/?trackingId=DtYTKH1hTl2aX%2BJzbHUBCQ%3D%3D&amp;refId=ESArOqZLSIa0FRSi3TELmw%3D%3D&amp;lipi=urn%3Ali%3Apage%3Aemail_email_application_confirmation_with_nba_01%3Bb9IDFRcFS6qoB9ZLRksCKw%3D%3D&amp;midToken=AQH_FbXyYqDADA&amp;midSig=1XtKsC_w_7jY81&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4370546733&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4370546733-null-px2gi~mlg3ii65~b4-null-null&amp;eid=px2gi-mlg3ii65-b4&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVkNDYxOGVlYjM4YmNlZDA0MzkxYTk4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjOTRhMjg1NmRkYWRmZjA2NzE3NmZmMjY2MTM5MDBjMDA1MzgxMDk5ZmE0YjE0Y2ZkLDEsMQ%3D%3D</url>
        <title>Atlassian Systems Administrator</title>
        <dates applied="2026-02-09" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Experts Group</company>
        <url>https://www.linkedin.com/comm/jobs/view/4281237572/?trackingId=KILZNnkSSzKSWUtjibEWMg%3D%3D&amp;refId=5EO0yz5BQQi2WTD6CvTjVQ%3D%3D&amp;lipi=urn%3Ali%3Apage%3Aemail_email_application_confirmation_with_nba_01%3B07mC%2FP%2BgQHi9f1LuvRcW4A%3D%3D&amp;midToken=AQH_FbXyYqDADA&amp;midSig=1XtKsC_w_7jY81&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4281237572&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4281237572-null-px2gi~mlg3j0r6~ao-null-null&amp;eid=px2gi-mlg3j0r6-ao&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVkNDYxOGVlYjM4YmNjZDQ0MjkxYWU4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjZDRkMDg1MTNiNmRiYzA1N2QwYWY0NjY5ZDMxNDUwYWM2MWQzNWNjMGVjZWQ5MGFlLDEsMQ%3D%3D</url>
        <title>ITSM Developer (Atlassian, JIRA)</title>
        <dates applied="2026-02-09" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>hatch I.T.</company>
        <url>https://www.linkedin.com/comm/jobs/view/4369825363/?trackingId=8WmO%2Bcx%2FSxeQiq2NXeloxg%3D%3D&amp;refId=%2FjUFuTbFRoi0Tf8aamvVWg%3D%3D&amp;lipi=urn%3Ali%3Apage%3Aemail_email_application_confirmation_with_nba_01%3BLZGd6cQgShio6SyMigogeA%3D%3D&amp;midToken=AQH_FbXyYqDADA&amp;midSig=2sLgplk_vhjY81&amp;trk=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4369825363&amp;trkEmail=eml-email_application_confirmation_with_nba_01-applied_jobs-0-jobcard_body_4369825363-null-px2gi~mlg3liqg~bh-null-null&amp;eid=px2gi-mlg3liqg-bh&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVkNDYxOGVlYmM4ZmNkZDY0NzlkYWE4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjZGRkMjkxNjBiOGIwZTQ0NGE5YjUzYjIyMTI5ODg3M2EyZjc0YTc3ODRmMjhiNzRhLDEsMQ%3D%3D</url>
        <title>Agile Tools &amp; Reporting SME</title>
        <dates applied="2026-02-09" rejected="2026-02-12"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Plenco</company>
        <url>https://www.indeed.com/jobs?q=%22Plastics+Engineering+Company%22&amp;l=Sheboygan%2C+WI&amp;rbc=%22Plastics+Engineering+Company%22&amp;jcid=e659d5532d9a6e16&amp;vjk=27fda979c6cedf3f&amp;advn=97130533630702</url>
        <title>Network Administrator</title>
        <dates applied="2026-02-11" rejected="2026-02-11"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Northland Plastics</company>
        <url>https://www.northlandplastics.com/about-npi-custom-plastic-extrusions/careers-plastic-profile-supplier/</url>
        <title>Northland Plastics</title>
        <dates applied="2026-02-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler</company>
        <url>https://kohler.csod.com/ux/ats/careersite/16/home?c=kohler&amp;cfdd[0][id]=214&amp;cfdd[0][options][0]=245&amp;country=us&amp;state=wi&amp;city=kohler&amp;date=WithinSevenDays&amp;lang=en-US#/requisition/70122</url>
        <title>Manager, Data Engineering</title>
        <dates applied="2026-02-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-24" type="Other">Jake Frye reviewed my LinkedIn page.</note>
            <note date="2026-03-25" type="Other">Sent LinkedIn message to Jake asking if he had any questions.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>VITS Consulting Corp</company>
        <url>https://www.dice.com/job-detail/0a6e5f09-642b-41f4-b89f-c8d4f3fab1de?page=2&amp;location=Kohler%2C+WI%2C+USA&amp;longitude=-87.7817541&amp;latitude=43.7391616&amp;locationPrecision=City&amp;countryCode=US&amp;adminDistrictCode=WI</url>
        <title>Enterprise Information / Data Architect</title>
        <dates applied="2026-02-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>General Dynamics</company>
        <url>https://gdit.wd5.myworkdayjobs.com/External_Career_Site/job/Systems-Analyst-Principal_RQ213918-1</url>
        <title>RQ213918 Systems Analyst Principal (C1883348)</title>
        <dates applied="2026-02-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>TekSystems</company>
        <url>https://www.linkedin.com/jobs/search/?alertAction=viewjobs&amp;currentJobId=4369915950&amp;distance=25&amp;f_TPR=a1770755398-&amp;f_WT=1%2C3%2C2&amp;geoId=103025842&amp;keywords=Robert%20Half&amp;origin=JOB_SEARCH_PAGE_SEARCH_BUTTON&amp;refresh=true&amp;sortBy=R</url>
        <title>Jira Administrator</title>
        <dates applied="2026-02-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Mango Languages</company>
        <url>https://www.linkedin.com/jobs/view/4363394243/?alternateChannel=search&amp;refId=IJAPlDxNVN4aRcgjesm3Dw%3D%3D&amp;trackingId=W2Gehm7vullba9%2FJH%2F7IKg%3D%3D</url>
        <title>Technical Project Manager (Remote, US)</title>
        <dates applied="2026-02-11" rejected="2026-02-23"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Meijer</company>
        <url>https://jobs.meijer.com/job/principal-engineer/-WI/R000641993-3/?source=LinkedIn</url>
        <title>Principal Engineer</title>
        <dates applied="2026-02-12" rejected="2026-03-14"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>rockITdata</company>
        <url>https://rockitdata.applytojob.com/apply/OIaBuFcVSu/Jira-Administrator?source=Our%20Career%20Page%20Widget</url>
        <title>Jira Administrator</title>
        <dates applied="2026-02-13" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Johnsonville</company>
        <url>https://careers.johnsonville.com/Johnsonville/job/Sheboygan-Falls-Enterprise-Master-Data-Coach-WI-53085/1365123200/</url>
        <title>Enterprise Master Data Manager</title>
        <dates applied="2026-02-16" rejected="2026-02-23"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>State Farm</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=f74bb89ee5d59587&amp;tk=1jiqk7l0ipft9800</url>
        <title>Account Representative</title>
        <dates applied="2026-02-17" rejected="2026-03-03"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-02-18" type="Other">Filled out math and personality checks.</note>
            <note date="2026-02-19" type="Other">Got a text saying I'm moving forward to the next stage in the interview process.</note>
            <note date="2026-02-24" type="Other">Submitted a contact us request on the State Farm site asking for assistance with the link.</note>
            <note date="2026-02-25" type="Other">Sent connection request to Amy Kalua.</note>
            <note date="2026-02-26" type="Other">Received same email. Looks like it was just resent, no changes. Replied again with a screenshot that it still does not work.</note>
            <note date="2026-03-03" type="Other">Met and found out starting base salary is 35k - 40k. Declined to continue.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22967037/it-systems-engineer-platform-management-remote/</url>
        <title>IT Systems Engineer - Platform management</title>
        <dates applied="2026-02-18" rejected="2026-03-17"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22967042/application-analyst-genesys-remote/</url>
        <title>Application Analyst-Genesys</title>
        <dates applied="2026-02-18" rejected="2026-03-01"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Millipore</company>
        <url>https://careers.emdgroup.com/us/en/job/MQAEGZUS295147EXTERNALENUS/OT-and-Automation-Engineer?ittk=A31PXSB86C&amp;jClickId=aaa058e5-cb09-4e5e-8811-04adbfe8c325&amp;utm_medium=ppc&amp;JoveoTrackingToken=&amp;utm_source=indeed_rsr</url>
        <title>OT and Automation Engineer</title>
        <dates applied="2026-02-18" rejected="2026-02-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Acuity</company>
        <url>https://recruiting2.ultipro.com/HER1001ACFIN/JobBoard/ab33798a-3521-417b-8db8-a8e435c475fa/OpportunityDetail?opportunityId=de0a0dfa-6886-4079-96db-9ce4cae7f79b</url>
        <title>Manager - Service Center</title>
        <dates applied="2026-02-20" rejected="2026-02-25"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>DMI</company>
        <url>https://careers-dminc.icims.com/jobs/28542/knowledge-manager---senior/job</url>
        <title>Knowledge Manager - Senior</title>
        <dates applied="2026-02-20" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>CVS</company>
        <url>https://cvshealth.wd1.myworkdayjobs.com/en-US/CVS_Health_Careers/job/ServiceNow-Scrum-Master-and-Business-Analyst_R0827426</url>
        <title>ServiceNow Scrum Master</title>
        <dates applied="2026-02-21" rejected="2026-02-24"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>CVS</company>
        <url>https://cvshealth.wd1.myworkdayjobs.com/en-US/CVS_Health_Careers/job/Manager---Digital-Product_R0822168</url>
        <title>Manager - Digital Product</title>
        <dates applied="2026-02-21" rejected="2026-02-24"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Prairie States Enterprises</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=b302507e0238711c&amp;tk=1ji6cjg17pfol800</url>
        <title>Data Integration Analyst</title>
        <dates applied="2026-02-22" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Kohler Credit Union</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=c8feae9debebee5d&amp;tk=1ji6cjg17pfol800</url>
        <title>Business Systems Manager</title>
        <dates applied="2026-02-22" rejected="2026-02-25"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-02-22" type="Other">Received email to fill in additional information for application.</note>
            <note date="2026-02-23" type="Other">Filled in additional information. (Event ID: KHL-FPs7-tjxX-21FTq)</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Viking Masek Packaging Technologies</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=4959242c6d1383a7&amp;tk=1ji6cjg17pfol800</url>
        <title>Project Manager</title>
        <dates applied="2026-02-22" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-02-23" type="Other">Received email from ClearCompany to fill out assessment. Done.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Cornerstone Caregiving</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=60db0de4cd72ca75&amp;tk=1ji6cjg17pfol800</url>
        <title>Operating Director</title>
        <dates applied="2026-02-22" rejected="2026-02-26"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Accion Labs</company>
        <url>https://www.linkedin.com/jobs/view/4374609194/?trackingId=la6UbE%2BlhgOhhNoJuU4VvQ%3D%3D&amp;refId=w953KMAX5oFZLH6axn31sw%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=0Yrc8k8MKPBs81&amp;trk=eml-email_job_alert_digest_01-primary_job_list-0-job_posting_0_jobid_4374609194_ssid_15620335708_fmid_px2gi~mlxuv8te~24&amp;trkEmail=eml-email_job_alert_digest_01-primary_job_list-0-job_posting_0_jobid_4374609194_ssid_15620335708_fmid_px2gi~mlxuv8te~24-null-px2gi~mlxuv8te~24-null-null&amp;eid=px2gi-mlxuv8te-24&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVkNDcxOWUwYjU4YmNjZDg0NTllYWY4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjOWZkMmEyNDdmMGI5ZTM2MTFlZjZkZDQ0Zjg4ZDMwYjkyMmMxYjZjYjIwM2FiMDkxLDEsMQ%3D%3D</url>
        <title>Jira Administrator</title>
        <dates applied="2026-02-23" rejected="2026-03-13"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Baird</company>
        <url>https://www.bairdcareers.com/jobs/r2026284/it-project-manager/</url>
        <title>IT Project Manager</title>
        <dates applied="2026-02-23" rejected="2026-02-28"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>WordRocket</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=fec684ca8b8a0ca0&amp;tk=1ji85uudsj7e7801</url>
        <title>Warranty and Service Coordinator</title>
        <dates applied="2026-02-23" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Hooper Corporation</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=68108243ff761af6&amp;tk=1ji85uudsj7e7801</url>
        <title>Project Coordinator - Mechanical</title>
        <dates applied="2026-02-23" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Sound Physicians</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=e45663a28a37dceb&amp;tk=1ji85uudsj7e7801</url>
        <title>Process Design Analyst, ACO</title>
        <dates applied="2026-02-23" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Routeware</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=6898efddca94f1ba&amp;tk=1ji85uudsj7e7801</url>
        <title>Technical Account Manager</title>
        <dates applied="2026-02-23" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Johnsonville</company>
        <url>https://careers.johnsonville.com/Johnsonville/job/Sheboygan-Falls-Manager%2C-Planning-Analytics-WI-53085/1366035500/</url>
        <title>Manager, Planning Analytics</title>
        <dates applied="2026-02-23" rejected="2026-03-16"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-09" type="Other">Received email asking for a phone interview. Replied with availability this week.</note>
            <note date="2026-03-10" type="Other">Interviewed with Bailey. 97-127k for pay. Gap is that this is ERP. Seemed to go pretty good.</note>
            <note date="2026-03-13" type="Other">Sent follow-up email.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>SASD</company>
        <url>https://wecan.waspa.org/Vacancy/25372</url>
        <title>Graphics Production Technician</title>
        <dates applied="2026-02-24" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22834521/analytics-solution-architect-remote/</url>
        <title>Analytics Solution Architect</title>
        <dates applied="2026-02-25" rejected="2026-03-01"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Aurora</company>
        <url>https://careers.aah.org/job/22923757/epic-application-analyst-sr-epic-professional-coding-remote/</url>
        <title>Epic Appliction Analyst Sr- Epic Professional Coding</title>
        <dates applied="2026-02-25" rejected="2026-03-07"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>DMI</company>
        <url>https://careers-dminc.icims.com/jobs/28541/knowledge-manager/job</url>
        <title>Knowledge Manager - Senior</title>
        <dates applied="2026-02-25" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>DMI</company>
        <url>https://careers-dminc.icims.com/jobs/28532/it-project-manager/job</url>
        <title>IT Project Manager</title>
        <dates applied="2026-02-25" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>DMI</company>
        <url>https://careers-dminc.icims.com/jobs/28526/project-analyst/job</url>
        <title>Project Analyst</title>
        <dates applied="2026-02-25" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Rehlko</company>
        <url>https://rehlko.wd12.myworkdayjobs.com/en-US/Reh/details/Sr-Systems-Analyst---CRM-Global-Services--AMPS_R02936-1?locations=29f2f7e3c4c5100107f5c1a167d50000&amp;locations=29f2f7e3c4c5100103be0631cecb0000&amp;locations=ce4ff45be118100103bd4a76cc860000</url>
        <title>Sr. System Analyst - CRM Global Services, AMPS</title>
        <dates applied="2026-02-25" rejected="2026-02-28"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Sargento</company>
        <url>https://careers.sargento.com/us/en/job/SFINUSOTNET003967EXTERNALENUS/Operational-Technology-OT-Engineer</url>
        <title>Operational Technology (OT) Engineer</title>
        <dates applied="2026-02-25" rejected="2026-02-26"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Courser</company>
        <url>https://www.indeed.com/viewjob?jk=6e44bf7148ed5dee&amp;q=full+time&amp;l=Sheboygan%2C+WI&amp;tk=1jib7gto0goa8800&amp;from=ja&amp;alid=698cba4277bc407f7174a9d4&amp;g1tAS=true&amp;xpse=SoAO67I3mLH6c9ARjL0LbzkdCdPP&amp;xfps=fd0cc764-ef19-4e04-b32a-ae2e1407c1f1&amp;utm_campaign=job_alerts&amp;utm_medium=email&amp;utm_source=jobseeker_emails&amp;rgtk=1jib7gto0goa8800&amp;xkcb=SoAR67M3mLHMKA6xWR0NbzkdCdPP</url>
        <title>Systems Engineer I</title>
        <dates applied="2026-02-25" rejected="2026-02-25"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Nemak</company>
        <url>https://careers.nemak.com/job/Sheboygan-NORIS-Specialist-WIS-Wisc/1292533801/?jobPipeline=Indeed</url>
        <title>NORIS Specialist WIS</title>
        <dates applied="2026-02-26" rejected=""/>
        <status>Interview</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-04" type="Other">Received call from Catherine Lediett asking for phone interview on 3-5-26 at 12:30pm. I accepted.</note>
            <note date="2026-03-05" type="Other">Had call with Catherine Lediett. Main issue is that I don't have a BS. 85k - 95k range. Supports both faclities in Sheboygan. 20 days of vacation and 2 person days.</note>
            <note date="2026-03-06" type="Other">I sent a follow-up email to Catherine thanking her for the interview.</note>
            <note date="2026-03-12" type="Other">Sent a follow-up email to Catherine asking for update and confirming interest.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Wells</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-saved-appcard&amp;hl=en&amp;jk=475e4851ff1aed6f&amp;tk=1jidmpncnppbg800</url>
        <title>BIM Administrator</title>
        <dates applied="2026-02-26" rejected="2026-02-26"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Rock River Laboratory</company>
        <url>https://www.indeed.com/viewjob?jk=e8e8d87813df5fae&amp;q=full+time&amp;l=Sheboygan%2C+WI&amp;tk=1jidotvfvga6u801&amp;from=ja&amp;advn=6317093132827225&amp;adid=457661275&amp;pub=4a1b367933fd867b19b072952f68dceb&amp;camk=UoKtGZLa3XKwGmXyMQLfHw%3D%3D&amp;xkcb=SoDf6_M3mN53xU1KGh0LbzkdCdPP&amp;xpse=SoA26_I3mN7Bbty-tR0PbzkdCdPP&amp;xfps=36faf093-1591-4947-846a-2f647da1abf8&amp;utm_campaign=job_alerts&amp;utm_medium=email&amp;utm_source=jobseeker_emails</url>
        <title>Software Engineer</title>
        <dates applied="2026-02-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Atlassian</company>
        <url>https://www.atlassian.com/company/careers/details/2471</url>
        <title>Senior Solutions Engineer | DX</title>
        <dates applied="2026-02-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-05" type="Other">Received email to fill in employment application at 12:15am.</note>
            <note date="2026-03-05" type="Other">Filled out employment application at 9:47am.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>American Orthodontics</company>
        <url>https://recruiting.ultipro.com/AME1064AMEOR/JobBoard/b76035b2-2f9c-49c0-a6e1-16bf401e522c/OpportunityDetail?opportunityId=8246542e-b3a4-4694-b074-35e5701e6d72</url>
        <title>Aplications Support Analyst - IT</title>
        <dates applied="2026-02-26" rejected="2026-03-06"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Experis</company>
        <url>https://www.linkedin.com/jobs/view/4376793542/?trackingId=PLW4l3hmQcWL%2Bnh4%2F7wCxw%3D%3D&amp;refId=qfoAUeTYSnmGj2RWdy86mg%3D%3D&amp;midToken=AQH_FbXyNqDADA&amp;midSig=3l64RTQQkjHI81&amp;trk=eml-email_jobs_viewed_job_reminder_01-job_card-0-job_posting&amp;trkEmail=eml-email_jobs_viewed_job_reminder_01-job_card-0-job_posting-null-px2gi~mm41rzqq~7c&amp;eid=px2gi-mm41rzqq-7c&amp;otpToken=MTYwNjFiZTMxMTJjY2FjMGJlMmYwMmVkNDQxZmUzYjE4OGM2ZDM0NTlhYWQ4NTY4NzhjNDA0Njk0NjVhNWFmN2ZjZDI5ZjllNmNiMGJhZjQ3Y2EzNjgxOTVmNDhhYzM5N2EyNDE2YWIxMDQzNDJlZmIzLDEsMQ%3D%3D</url>
        <title>Jira Administrator</title>
        <dates applied="2026-02-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Experis</company>
        <url/>
        <title>IT Automation Support Specialist</title>
        <dates applied="2026-02-26" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>West Bend Insurance Company</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=85b4974851dc2278&amp;tk=1jig8o6tgi5qd800</url>
        <title>Associate Experience Analyst</title>
        <dates applied="2026-02-26" rejected="2026-03-03"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Xtivia</company>
        <url>https://recruiting.paylocity.com/Recruiting/Jobs/Details/395606</url>
        <title>ITSM Consultant - Jira Service Management</title>
        <dates applied="2026-02-27" rejected="2026-03-03"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Bureau of STAR</company>
        <url>https://wj.wi.gov/psc/wisjobs/CAREERS/HRMS/c/HRS_HRAM_FL.HRS_CG_SEARCH_FL.GBL?Page=HRS_APP_JBPST_FL&amp;Action=U&amp;FOCUS=Applicant&amp;SiteId=1&amp;PostingSeq=1&amp;JobOpeningId=20139</url>
        <title>Procurement Business Analyst</title>
        <dates applied="2026-03-01" rejected="2026-03-19"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>DOA</company>
        <url>https://wj.wi.gov/psc/wisjobs/CAREERS/HRMS/c/HRS_HRAM_FL.HRS_CG_SEARCH_FL.GBL?Page=HRS_APP_JBPST_FL&amp;Action=U&amp;FOCUS=Applicant&amp;SiteId=1&amp;PostingSeq=1&amp;JobOpeningId=18780</url>
        <title>Database Administrator</title>
        <dates applied="2026-03-01" rejected="2026-03-20"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>WED</company>
        <url>https://secure2.yourpayrollhr.com/ta/7760.careers?CareersSearch=&amp;ein_id=683792&amp;lang=en-US</url>
        <title>IT Systems Analyst</title>
        <dates applied="2026-03-01" rejected="2026-03-25"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Theoris Services</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=9acff9a55238db89&amp;tk=1jiqkq65jtkrp800</url>
        <title>Interface Business Analyst</title>
        <dates applied="2026-03-01" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Genesis10</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=9acff9a55238db89&amp;tk=1jiqkq65jtkrp800</url>
        <title>Senior Business Analyst</title>
        <dates applied="2026-03-01" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Landmark Credit Union</company>
        <url/>
        <title>Data Governance</title>
        <dates applied="2026-03-03" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Dayton T. Brown</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=d79d70d612bd4f9e&amp;tk=1jiqkq65jtkrp800</url>
        <title>Technical Publication Solution Architect</title>
        <dates applied="2026-03-03" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Zuri Group</company>
        <url>https://www.linkedin.com/jobs/view/4378482911/?alternateChannel=search&amp;trackingId=yeff08zuRqe4cUQhl2xfcw%3D%3D</url>
        <title>Scrum Master (JIRA &amp; Confluence Administrator)</title>
        <dates applied="2026-03-06" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>XALT Business Consulting GmbH</company>
        <url>https://www.linkedin.com/jobs/view/4381602936/?alternateChannel=search&amp;trackingId=UarqFVrPThSgQafYtizAMQ%3D%3D</url>
        <title>Atlassian AI Consultant (m/f/d)</title>
        <dates applied="2026-03-06" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Symetra</company>
        <url>https://symetra.eightfold.ai/careers/job/446715534662?utm_source=linkedin&amp;domain=symetra.com</url>
        <title>Sr. Software Engineer II</title>
        <dates applied="2026-03-06" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Brown Jordan</company>
        <url>https://www.indeed.com/viewjob?jk=a9897e8b8c31b3b8</url>
        <title>Business Analyst - Web/E-Commerce</title>
        <dates applied="2026-03-06" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Citizant Inc</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=39bd01cea5a67b1f&amp;tk=1jj9jongrg6q4800</url>
        <title>Senior Computer Systems Analyst</title>
        <dates applied="2026-03-07" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Robert Half</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=8b21d45c5a5baa4c&amp;tk=1jj9jongrg6q4800</url>
        <title>Senior Project Engineer</title>
        <dates applied="2026-03-07" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Ascension</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=8ecb753bda5a5857&amp;tk=1jj9jongrg6q4800</url>
        <title>Senior Quality Analyst Business Systems</title>
        <dates applied="2026-03-07" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-09" type="Other">Received email to complete a separate online application.</note>
            <note date="2026-03-09" type="Other">Filled out application.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Tech Soft Inc</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=5445c09469a68198&amp;tk=1jj9jongrg6q4800</url>
        <title>Integration Analyst</title>
        <dates applied="2026-03-07" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Genersis10</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=0cde28a196a72564&amp;tk=1jj9jongrg6q4800</url>
        <title>Data Governance Analyst</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>GovCIO</company>
        <url>https://govcio.com/jobs/sr-clinical-ai-technical-integration-specialist-remote/</url>
        <title>Sr. Clinical AI Technical Integration Specialist (Remote)</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Randstad</company>
        <url>https://www.randstadusa.com/jobs/4/1326537/it-project-manager_kohler/</url>
        <title>IT Project Manager</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>First Citizens Bank</company>
        <url>https://jobs.firstcitizens.com/jobs/30682?lang=en-us</url>
        <title>Senior Business Data Analyst</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Brown &amp; Brown Inc.</company>
        <url>https://bbinsurance.wd1.myworkdayjobs.com/en-US/Careers/details/Business-Intelligence-Analyst_R25_0000003381</url>
        <title>Business Intelligence Analyst</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Honor!</company>
        <url>https://job-boards.greenhouse.io/honor/jobs/8451598002</url>
        <title>Staff Data Analyst</title>
        <dates applied="2026-03-08" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>American Eagle Outfitters</company>
        <url/>
        <title>PIM Implementation Specialist Apolois</title>
        <dates applied="2026-03-09" rejected=""/>
        <status>Interview</status>
        <notes>
            <note date="" type=""/>
            <note date="2026-03-09" type="Other">This is a recruiter email from Pravin.pandey@apolisrises.com. I replied.</note>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>CGS Federal</company>
        <url>https://www.linkedin.com/jobs/view/4382115856</url>
        <title>Jira Lead Administrator</title>
        <dates applied="2026-03-10" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Sartori</company>
        <url>https://www.indeed.com/viewjob?jk=54aea64ced215295&amp;l=Sheboygan%2C+WI&amp;tk=1jjdl2unbg4uh800&amp;from=ja&amp;advn=8692197930477261&amp;adid=440442080&amp;sjdu=o4-SOnWFj7zDQa1x_oNfXa_R7B8ER0FmKubju5dV3zOQeSOzFgK4iCVDET44iIcwlYg5wFic3iSe67qsHiF4rW7M-HlcJN0Zs4cE9lxqwMJUErt50y6856cqY1ntqjSQhRc4DqFy4y9GWcoAWScwAKMrEWrGC0N3uej-d8nIbCq-gCfvRVD2GtYmZXHoDPhHMgJzUd0UxxHHKKYIc9Un5q_B0wSqBIjpIW7bIW8ULxZl3ceNddtAZJAVoFQQ96V-4NEIym96afv1Y9Q5ltiyZA&amp;acatk=1jjeq7b4vgdn3802&amp;alid=69a105d0c28ed00b24715995&amp;pub=4a1b367933fd867b19b072952f68dceb&amp;camk=ethIe0s0hefyGIqPW84bFg%3D%3D&amp;xkcb=SoCV6_M3mtiD0HU39R04bzkdCdPP&amp;xpse=SoDC6_I3mu8Sv6yOyx0PbzkdCdPP&amp;xfps=2f29346c-ff7d-44ff-97d1-6d1fc29ffad1&amp;utm_campaign=job_alerts&amp;utm_medium=email&amp;utm_source=jobseeker_emails</url>
        <title>Applications Operations Analyst</title>
        <dates applied="2026-03-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>CSAA Insurance Group</company>
        <url>https://jobright.ai/jobs/info/69b161dc548f140066e726df?utm_source=1025&amp;imp_id=3714812182199200984__digest_job_alert__1773245357467_920&amp;utm_medium=email</url>
        <title>API IT Solutions Analyst IV - Remote</title>
        <dates applied="2026-03-11" rejected="2026-03-14"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Milliman</company>
        <url>https://recruiting2.ultipro.com/MIL1017/JobBoard/f54234e9-dfde-b183-fd20-4fbdb19cba7a/OpportunityDetail?opportunityId=b1e3313f-dcf8-4f2e-9dea-de4d1a11a377</url>
        <title>Scrum Master - IntelliScript (Remote)</title>
        <dates applied="2026-03-11" rejected="2026-03-12"/>
        <status>Rejected</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Two Six Technologies</company>
        <url>https://jobright.ai/jobs/info/69b1c04165de58104c70bcd9?utm_source=1121&amp;imp_id=3714812182199200984__instant_push__1773257661013_4078&amp;utm_medium=email</url>
        <title>Intel Analyst</title>
        <dates applied="2026-03-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Links Technology Solutions</company>
        <url>https://www.indeed.com/viewjob?from=app-tracker-post_apply-appcard&amp;hl=en&amp;jk=23103996eb3968b2&amp;tk=1jjhdc8njrmqt800</url>
        <title>Principal Technical Systems Administrator</title>
        <dates applied="2026-03-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>

    <job id="">
        <company>Rehlko</company>
        <url>https://www.indeed.com/viewjob?jk=0a3530902331ad3a&amp;tk=1jjgee7ichb6e802&amp;from=jobi2a&amp;advn=323539756744737&amp;adid=442685037&amp;ad=-6NYlbfkN0DNRstKI9rbJpFCiCqdv6VfjfqcAuzOwjyNPWXFu_IWIMaLrHCA-a3v_1sDzJkVB_-4wbRY_JldevaUwDkhvENr2hoEtbdw938yPHLoD7ybg5YVmmi-LrkedYJ6kS5OMqIoXXsA74Km0L_ZU_B6x28BnR3_3_jcr6F0V93kzkuw1jrlbchdkmXtsD5TkR417mZ5dOPg3FeNpaO7klsLduQxfjbGGdj8GSjYmUxBargTvWR3RbOPaPtX5R8arRbcYvSTFpDoqCVQPyHqwr15lX_WnaWRUcvV0cdXIcKMmw1Mc12kNtJnSDwLUQuKu3z8EKrKrQX27mJQaxpobA7LIKR2f8MZjo-hor4kqs6VHMu72MxCuMvBl6se5VIZCG3P0rlpZmPcm7y44VqOLBveDFVIV4NpNjMLN5ejWq860hSTADNLXeLORItNU-RAg3ZdKYARpqYk-hFXK86s1EvOhws_2iNVp-wr4i69qwAMxB8BWY9EsSwBssG9SOwPbNQJsr-2DHYTfOU22rUPqnxPUFEe2Hx67zJw-ig_bMNHOfOMx8jjlOhDmNlN_R9xA9QqmzNIfQsWzxF_O31TZExjl</url>
        <title>Senior New Product Development (NPD) Project Leader</title>
        <dates applied="2026-03-11" rejected=""/>
        <status>Submitted</status>
        <notes>
            <note date="" type=""/>
        </notes>
        <contacts>
           <contact mail="" phone=""/>
        </contacts>
    </job>
</jobs>;


(: 3. Ensure target collection exists :)
let $ensureCollection := 
    if (not(xmldb:collection-available($targetCollection))) then
        xmldb:create-collection("/db/jobs", "applications")
    else ()

(: 4. Loop through each job and burst them :)
for $job in $bulkJobs/job
    (: Generate UUID :)
    let $uid := util:uuid()
    let $filename := concat($uid, ".xml")
    
    (: Reconstruct element with the new ID in the @id attribute :)
    let $processedJob := 
        <job id="{$uid}">
            {$job/node()[not(self::attribute(id))]}
        </job>

    (: Store the newly minted XML file into eXist-db :)
    let $store := xmldb:store($targetCollection, $filename, $processedJob)

    return 
        <p>Stored: {$filename} ({$job/company/string()} - {$job/title/string()})</p>