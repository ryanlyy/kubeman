<map version="freeplane 1.7.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="ksys_unshare" FOLDED="false" ID="ID_1402599493" CREATED="1615530275521" MODIFIED="1615530336845" STYLE="oval">
<font SIZE="18"/>
<hook NAME="MapStyle">
    <properties fit_to_viewport="false" edgeColorConfiguration="#808080ff,#ff0000ff,#0000ffff,#00ff00ff,#ff00ffff,#00ffffff,#7c0000ff,#00007cff,#007c00ff,#7c007cff,#007c7cff,#7c7c00ff"/>

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node" STYLE="oval" UNIFORM_SHAPE="true" VGAP_QUANTITY="24.0 pt">
<font SIZE="24"/>
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="default" ICON_SIZE="12.0 pt" COLOR="#000000" STYLE="fork">
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.attributes">
<font SIZE="9"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.note" COLOR="#000000" BACKGROUND_COLOR="#ffffff" TEXT_ALIGN="LEFT"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important">
<icon BUILTIN="yes"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000" STYLE="oval" SHAPE_HORIZONTAL_MARGIN="10.0 pt" SHAPE_VERTICAL_MARGIN="10.0 pt">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,5"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,6"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,7"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,8"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,9"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,10"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,11"/>
</stylenode>
</stylenode>
</map_styles>
</hook>
<hook NAME="AutomaticEdgeColor" COUNTER="5" RULE="ON_BRANCH_CREATION"/>
<node TEXT="unshare_fs(unshare_flags, &amp;new_fs);" POSITION="right" ID="ID_1214396427" CREATED="1615530728094" MODIFIED="1615530733840">
<edge COLOR="#ff0000"/>
<node TEXT="MNT/USER: *new_fsp = copy_fs_struct(current-&gt;fs);" ID="ID_863575033" CREATED="1615530918487" MODIFIED="1615531036165"/>
</node>
<node TEXT="unshare_fd(unshare_flags, &amp;new_fd)" POSITION="right" ID="ID_1508656712" CREATED="1615530736360" MODIFIED="1615530744558">
<edge COLOR="#0000ff"/>
<node TEXT="*new_fdp = dup_fd(fd, &amp;error)" ID="ID_1018600696" CREATED="1615531147121" MODIFIED="1615531151475"/>
</node>
<node TEXT="unshare_userns(unshare_flags, &amp;new_cred)" POSITION="right" ID="ID_401461218" CREATED="1615530754065" MODIFIED="1615530764953">
<edge COLOR="#00ff00"/>
<node TEXT="*new_cred = create_user_ns( prepare_creds())" ID="ID_1301020546" CREATED="1615531205556" MODIFIED="1615531261105"/>
</node>
<node TEXT="unshare_nsproxy_namespaces(unshare_flags, &amp;new_nsproxy, new_cred, new_fs) under CAP_SYS_ADMIN" POSITION="right" ID="ID_170000321" CREATED="1615530765781" MODIFIED="1615531455413">
<edge COLOR="#ff00ff"/>
<node TEXT=" *new_nsp = create_new_namespaces(unshare_flags, current, user_ns, new_fs ? new_fs : current-&gt;fs);" ID="ID_1868899648" CREATED="1615531477330" MODIFIED="1615531580727">
<node ID="ID_1899478299" CREATED="1615531542697" MODIFIED="1615865773909"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>mnt</b>_ns = copy_mnt_ns(flags, tsk-&gt;nsproxy-&gt;mnt_ns, user_ns, new_fs)
    </p>
  </body>
</html>

</richcontent>
</node>
<node ID="ID_1929679773" CREATED="1615531555095" MODIFIED="1615531688238"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>uts</b>_ns = copy_utsname(flags, user_ns, tsk-&gt;nsproxy-&gt;uts_ns);
    </p>
  </body>
</html>
</richcontent>
</node>
<node ID="ID_1754663031" CREATED="1615531569864" MODIFIED="1615531694449"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>ipc</b>_ns = copy_ipcs(flags, user_ns, tsk-&gt;nsproxy-&gt;ipc_ns);
    </p>
  </body>
</html>
</richcontent>
<node TEXT="create_ipc_ns(user_ns, ns)" ID="ID_707509293" CREATED="1615531818818" MODIFIED="1615536586929">
<node TEXT="sem_init_ns(ns)" ID="ID_430554304" CREATED="1615531875544" MODIFIED="1615531876381">
<node TEXT="ns-&gt;sc_semmsl = SEMMSL;&#xa;ns-&gt;sc_semmns = SEMMNS;&#xa;ns-&gt;sc_semopm = SEMOPM;&#xa;ns-&gt;sc_semmni = SEMMNI;" ID="ID_155039126" CREATED="1615534440282" MODIFIED="1615534457766"/>
</node>
<node TEXT="msg_init_ns(ns)" ID="ID_476482284" CREATED="1615531883474" MODIFIED="1615531884236">
<node TEXT="ns-&gt;msg_ctlmax = MSGMAX;&#xa;ns-&gt;msg_ctlmnb = MSGMNB;&#xa;ns-&gt;msg_ctlmni = MSGMNI;" ID="ID_185391499" CREATED="1615537110785" MODIFIED="1615537119750"/>
</node>
<node TEXT="shm_init_ns(ns)" ID="ID_1600557556" CREATED="1615531892660" MODIFIED="1615531893823">
<node TEXT="ns-&gt;shm_ctlmax = SHMMAX;&#xa;ns-&gt;shm_ctlall = SHMALL;&#xa;ns-&gt;shm_ctlmni = SHMMNI;" ID="ID_1232991559" CREATED="1615537494305" MODIFIED="1615537502294"/>
</node>
<node TEXT="mq_init_ns(ns)" ID="ID_1116691920" CREATED="1615531900835" MODIFIED="1615531901308">
<node TEXT="ns-&gt;mq_queues_max    = DFLT_QUEUESMAX;&#xa;ns-&gt;mq_msg_max       = DFLT_MSGMAX;&#xa;ns-&gt;mq_msgsize_max   = DFLT_MSGSIZEMAX;&#xa;ns-&gt;mq_msg_default   = DFLT_MSG;&#xa;ns-&gt;mq_msgsize_default  = DFLT_MSGSIZE;" ID="ID_1137353016" CREATED="1615537716388" MODIFIED="1615537731059"/>
</node>
</node>
</node>
<node ID="ID_1138830417" CREATED="1615531572914" MODIFIED="1615531701415"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>pid</b>_ns_for_children = copy_pid_ns(flags, user_ns, tsk-&gt;nsproxy-&gt;pid_ns_for_children);
    </p>
  </body>
</html>
</richcontent>
</node>
<node ID="ID_714568761" CREATED="1615531588681" MODIFIED="1615531706397"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>cgroup</b>_ns = copy_cgroup_ns(flags, user_ns, tsk-&gt;nsproxy-&gt;cgroup_ns);
    </p>
  </body>
</html>
</richcontent>
</node>
<node ID="ID_568099869" CREATED="1615531597602" MODIFIED="1615531714318"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      new_nsp-&gt;<b>net</b>_ns = copy_net_ns(flags, user_ns, tsk-&gt;nsproxy-&gt;net_ns);
    </p>
  </body>
</html>
</richcontent>
<node TEXT="setup_net(net, user_ns)" ID="ID_711626722" CREATED="1615537994907" MODIFIED="1615537997920">
<node ID="ID_228296344" CREATED="1615538623063" MODIFIED="1615538714446"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      list_for_each_entry(ops, &amp;<b>pernet_list</b>, list)
    </p>
    <p>
      &#160;&#160;error = <b>ops_init</b>(ops, net);
    </p>
  </body>
</html>
</richcontent>
<node TEXT="ops-&gt;init(net)" ID="ID_760371698" CREATED="1615538763997" MODIFIED="1615538766037">
<node TEXT="devinet_init_net" ID="ID_1003022749" CREATED="1615859794212" MODIFIED="1615861037989">
<node TEXT="ipv4_devconf" ID="ID_1240180759" CREATED="1615864954410" MODIFIED="1615864955574"/>
<node TEXT="ipv4_devconf_dflt" ID="ID_1777123902" CREATED="1615864961443" MODIFIED="1615864962984"/>
</node>
<node TEXT="loopback_net_init" ID="ID_474966292" CREATED="1615861038835" MODIFIED="1615861068537">
<node TEXT="register_netdev(dev)" ID="ID_1232758262" CREATED="1615865117168" MODIFIED="1615865118510">
<node TEXT="register_netdevice(dev)" ID="ID_925060610" CREATED="1615865138461" MODIFIED="1615865139424">
<node TEXT="call_netdevice_notifiers(NETDEV_REGISTER, dev)" ID="ID_1018997461" CREATED="1615865164958" MODIFIED="1615865165986">
<node TEXT="IPV4 - inetdev_event" ID="ID_1611598666" CREATED="1615865175759" MODIFIED="1615865183202">
<node TEXT="NETDEV_REGISTER - inetdev_init" ID="ID_993420999" CREATED="1615865209149" MODIFIED="1615865241506">
<node TEXT="devconf_dflt" ID="ID_1532958350" CREATED="1615865257173" MODIFIED="1615865259056"/>
</node>
</node>
<node TEXT="IPV6 - inetdev_event" ID="ID_1872043601" CREATED="1615865183763" MODIFIED="1615865193831">
<node TEXT="NETDEV_REGISTER - ipv6_add_dev(dev)" ID="ID_1698218319" CREATED="1615865225689" MODIFIED="1615865236487">
<node TEXT="ipv6_devconf_dflt" ID="ID_107587494" CREATED="1615865260085" MODIFIED="1615865285031"/>
</node>
</node>
</node>
</node>
</node>
</node>
<node TEXT="......" ID="ID_47503206" CREATED="1615861144174" MODIFIED="1615861309453"/>
<node TEXT="......" ID="ID_1123989337" CREATED="1615861146914" MODIFIED="1615861325118"/>
</node>
</node>
<node ID="ID_1683971399" CREATED="1615538666888" MODIFIED="1615538722710"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      list_add_tail_rcu(&amp;net-&gt;list, &amp;<b>net_namespace_list</b>)
    </p>
  </body>
</html>
</richcontent>
</node>
</node>
</node>
</node>
</node>
<node TEXT="IF CLONE_NEWIPC, shm_init_task(current)" POSITION="right" ID="ID_1752120985" CREATED="1615531382070" MODIFIED="1615531405353">
<edge COLOR="#00ffff"/>
</node>
</node>
</map>
