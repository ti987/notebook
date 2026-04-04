PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "keywords" (
	"k_id"	INTEGER UNIQUE,
	"keyword"	TEXT,
	PRIMARY KEY("k_id" AUTOINCREMENT)
);
INSERT INTO keywords VALUES(10,'#:tag_test');
INSERT INTO keywords VALUES(11,'#:delete_this_test');
INSERT INTO keywords VALUES(12,'#:tag3');
INSERT INTO keywords VALUES(13,'#:tag');
INSERT INTO keywords VALUES(14,'#:test_tag');
INSERT INTO keywords VALUES(15,'#:hello');
INSERT INTO keywords VALUES(20,'#:verification');
INSERT INTO keywords VALUES(21,'#:RST');
INSERT INTO keywords VALUES(22,'#:notebook');
INSERT INTO keywords VALUES(23,'#:cell_placement');
INSERT INTO keywords VALUES(24,'#:clocks');
INSERT INTO keywords VALUES(25,'#:Verification');
INSERT INTO keywords VALUES(26,'#:password');
INSERT INTO keywords VALUES(27,'#:cssh');
INSERT INTO keywords VALUES(28,'#:fpganodes');
INSERT INTO keywords VALUES(29,'#:flicker_noise');
INSERT INTO keywords VALUES(30,'#:RTAX');
INSERT INTO keywords VALUES(31,'#:agile');
INSERT INTO keywords VALUES(32,'#:code_for_change');
INSERT INTO keywords VALUES(33,'#:vivado');
INSERT INTO keywords VALUES(34,'#:module');
INSERT INTO keywords VALUES(35,'#:environment');
INSERT INTO keywords VALUES(36,'#:FPGA');
INSERT INTO keywords VALUES(37,'#:test');
INSERT INTO keywords VALUES(38,'#:actel');
INSERT INTO keywords VALUES(39,'#:libero');
INSERT INTO keywords VALUES(40,'#:actel_wuclean');
INSERT INTO keywords VALUES(41,'#:router');
INSERT INTO keywords VALUES(42,'#:glinet');
INSERT INTO keywords VALUES(43,'#:network');
INSERT INTO keywords VALUES(44,'#:linux');
INSERT INTO keywords VALUES(45,'#:uvm');
INSERT INTO keywords VALUES(46,'#:pdf');
INSERT INTO keywords VALUES(47,'#:scan');
INSERT INTO keywords VALUES(48,'#:encrypt');
INSERT INTO keywords VALUES(49,'#:printer');
INSERT INTO keywords VALUES(50,'#:ubuntu');
CREATE TABLE IF NOT EXISTS "article_links" (
	"al_id"	INTEGER UNIQUE,
	"a_id_1"	INTEGER,
	"a_id_2"	INTEGER,
	PRIMARY KEY("al_id" AUTOINCREMENT)
);
INSERT INTO article_links VALUES(1,31,33);
INSERT INTO article_links VALUES(2,26,23);
INSERT INTO article_links VALUES(3,26,24);
INSERT INTO article_links VALUES(4,26,25);
INSERT INTO article_links VALUES(5,28,22);
INSERT INTO article_links VALUES(12,33,69);
INSERT INTO article_links VALUES(13,22,53);
INSERT INTO article_links VALUES(14,22,67);
INSERT INTO article_links VALUES(16,68,66);
INSERT INTO article_links VALUES(17,68,67);
INSERT INTO article_links VALUES(18,82,81);
INSERT INTO article_links VALUES(19,83,1);
INSERT INTO article_links VALUES(20,84,83);
INSERT INTO article_links VALUES(21,85,84);
INSERT INTO article_links VALUES(22,88,87);
INSERT INTO article_links VALUES(23,93,85);
INSERT INTO article_links VALUES(24,96,44);
INSERT INTO article_links VALUES(25,97,44);
INSERT INTO article_links VALUES(26,98,97);
INSERT INTO article_links VALUES(27,102,101);
CREATE TABLE IF NOT EXISTS "files" (
	"f_id"	INTEGER UNIQUE,
	"file"	BLOB,
	PRIMARY KEY("f_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "file_links" (
	"fl_id"	INTEGER UNIQUE,
	"a_id"	INTEGER,
	"f_id"	INTEGER,
	PRIMARY KEY("fl_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "keyword_links" (
	"kl_id"	INTEGER UNIQUE,
	"a_id"	INTEGER,
	"k_id"	INTEGER,
	PRIMARY KEY("kl_id" AUTOINCREMENT)
);
INSERT INTO keyword_links VALUES(15,66,10);
INSERT INTO keyword_links VALUES(16,66,11);
INSERT INTO keyword_links VALUES(17,67,10);
INSERT INTO keyword_links VALUES(18,67,11);
INSERT INTO keyword_links VALUES(19,68,11);
INSERT INTO keyword_links VALUES(20,68,12);
INSERT INTO keyword_links VALUES(21,71,13);
INSERT INTO keyword_links VALUES(22,71,14);
INSERT INTO keyword_links VALUES(23,71,15);
INSERT INTO keyword_links VALUES(33,72,15);
INSERT INTO keyword_links VALUES(34,46,20);
INSERT INTO keyword_links VALUES(35,46,21);
INSERT INTO keyword_links VALUES(36,46,20);
INSERT INTO keyword_links VALUES(37,46,21);
INSERT INTO keyword_links VALUES(38,47,20);
INSERT INTO keyword_links VALUES(39,47,21);
INSERT INTO keyword_links VALUES(40,48,20);
INSERT INTO keyword_links VALUES(41,48,21);
INSERT INTO keyword_links VALUES(42,45,20);
INSERT INTO keyword_links VALUES(43,45,21);
INSERT INTO keyword_links VALUES(44,53,10);
INSERT INTO keyword_links VALUES(45,68,11);
INSERT INTO keyword_links VALUES(46,68,12);
INSERT INTO keyword_links VALUES(47,73,10);
INSERT INTO keyword_links VALUES(48,74,10);
INSERT INTO keyword_links VALUES(49,75,10);
INSERT INTO keyword_links VALUES(50,76,10);
INSERT INTO keyword_links VALUES(51,77,10);
INSERT INTO keyword_links VALUES(52,78,10);
INSERT INTO keyword_links VALUES(53,79,10);
INSERT INTO keyword_links VALUES(54,80,10);
INSERT INTO keyword_links VALUES(55,81,10);
INSERT INTO keyword_links VALUES(56,82,10);
INSERT INTO keyword_links VALUES(57,1,22);
INSERT INTO keyword_links VALUES(58,83,22);
INSERT INTO keyword_links VALUES(59,84,22);
INSERT INTO keyword_links VALUES(60,85,22);
INSERT INTO keyword_links VALUES(61,86,22);
INSERT INTO keyword_links VALUES(62,86,22);
INSERT INTO keyword_links VALUES(63,87,21);
INSERT INTO keyword_links VALUES(64,87,23);
INSERT INTO keyword_links VALUES(65,87,21);
INSERT INTO keyword_links VALUES(66,87,23);
INSERT INTO keyword_links VALUES(67,87,21);
INSERT INTO keyword_links VALUES(68,87,23);
INSERT INTO keyword_links VALUES(69,88,21);
INSERT INTO keyword_links VALUES(70,88,23);
INSERT INTO keyword_links VALUES(71,88,21);
INSERT INTO keyword_links VALUES(72,88,23);
INSERT INTO keyword_links VALUES(73,88,24);
INSERT INTO keyword_links VALUES(74,90,21);
INSERT INTO keyword_links VALUES(75,90,25);
INSERT INTO keyword_links VALUES(76,90,21);
INSERT INTO keyword_links VALUES(77,90,25);
INSERT INTO keyword_links VALUES(78,90,21);
INSERT INTO keyword_links VALUES(79,90,20);
INSERT INTO keyword_links VALUES(80,91,26);
INSERT INTO keyword_links VALUES(81,91,27);
INSERT INTO keyword_links VALUES(82,91,28);
INSERT INTO keyword_links VALUES(83,92,29);
INSERT INTO keyword_links VALUES(84,92,29);
INSERT INTO keyword_links VALUES(85,41,30);
INSERT INTO keyword_links VALUES(86,36,31);
INSERT INTO keyword_links VALUES(87,36,32);
INSERT INTO keyword_links VALUES(88,93,22);
INSERT INTO keyword_links VALUES(89,94,33);
INSERT INTO keyword_links VALUES(90,95,34);
INSERT INTO keyword_links VALUES(91,95,35);
INSERT INTO keyword_links VALUES(92,95,36);
INSERT INTO keyword_links VALUES(93,96,37);
INSERT INTO keyword_links VALUES(94,98,38);
INSERT INTO keyword_links VALUES(95,98,39);
INSERT INTO keyword_links VALUES(96,98,40);
INSERT INTO keyword_links VALUES(97,98,38);
INSERT INTO keyword_links VALUES(98,98,39);
INSERT INTO keyword_links VALUES(99,98,40);
INSERT INTO keyword_links VALUES(100,97,38);
INSERT INTO keyword_links VALUES(101,97,39);
INSERT INTO keyword_links VALUES(102,97,40);
INSERT INTO keyword_links VALUES(103,44,38);
INSERT INTO keyword_links VALUES(104,44,39);
INSERT INTO keyword_links VALUES(105,44,40);
INSERT INTO keyword_links VALUES(106,98,38);
INSERT INTO keyword_links VALUES(107,98,39);
INSERT INTO keyword_links VALUES(108,98,40);
INSERT INTO keyword_links VALUES(109,101,10);
INSERT INTO keyword_links VALUES(110,102,10);
INSERT INTO keyword_links VALUES(111,103,41);
INSERT INTO keyword_links VALUES(112,103,42);
INSERT INTO keyword_links VALUES(113,104,43);
INSERT INTO keyword_links VALUES(114,104,44);
INSERT INTO keyword_links VALUES(115,106,45);
INSERT INTO keyword_links VALUES(116,107,46);
INSERT INTO keyword_links VALUES(117,107,47);
INSERT INTO keyword_links VALUES(118,107,48);
INSERT INTO keyword_links VALUES(119,107,46);
INSERT INTO keyword_links VALUES(120,107,47);
INSERT INTO keyword_links VALUES(121,107,48);
INSERT INTO keyword_links VALUES(122,108,49);
INSERT INTO keyword_links VALUES(123,108,50);
INSERT INTO keyword_links VALUES(124,108,44);
CREATE TABLE IF NOT EXISTS "articles" (
	"a_id"	INTEGER UNIQUE,
	"a_body"	TEXT NOT NULL,
	"a_info_type"	TEXT,
	"a_title"	TEXT NOT NULL,
	"a_status"	INTEGER DEFAULT 0,
	"a_mod_date"	TEXT,
	"a_datetime"	TEXT,
	PRIMARY KEY("a_id" AUTOINCREMENT)
);
INSERT INTO articles VALUES(1,replace(replace('creating notebook database and php scripts\r\n#:notebook\r\n\r\n','\r',char(13)),'\n',char(10)),'','notebook development',0,'2022-01-05 17:16','2021-11-30 13:00');
INSERT INTO articles VALUES(2,'layout added','','layout',0,'','2021-11-30 13:40');
INSERT INTO articles VALUES(3,'new body',NULL,'<del>new title</del>',0,'','2021-11-30 16:33');
INSERT INTO articles VALUES(8,'body 9 ',NULL,'test 9',0,'','2021-11-30 17:05');
INSERT INTO articles VALUES(9,replace(replace('It is a suggestion from NASA to obtain the temperature that breaks the timing requirements. \r\nThe timing constraints are based on the worst case timing values in datasheets of other devices (processor,MRAM, SRAM) and trace delay worst cases. Those values are the value at their worst case/environment. Because the FPGA max temperature is relatively low (66c), it is very unlikely for other devices are at the worst. They allow extra time to the FPGA and therefore the board level timings still meet and continue to work properly even if raising the temperature to the point that the FPGA timing analysis fails. While temperature rises, the FPGA internal signals start break the limits. It is not feasible or beneficial to obtain the temperature that board level timings break. ','\r',char(13)),'\n',char(10)),NULL,'Obtaining temperature that breaks timing requirements',0,'','2021-11-30 17:22');
INSERT INTO articles VALUES(22,'test permanent index','','just a test',0,'2022-01-21 18:33','2021-12-01 09:51');
INSERT INTO articles VALUES(23,replace(replace(' &lt;h1&gt; H1 here &lt;/h1&gt;\r\n&lt;ol&gt; ordered list &lt;br&gt;\r\n&lt;li&gt; first &lt;/li&gt;\r\n&lt;li&gt; second &lt;/li&gt;\r\n&lt;li&gt; third &lt;/li&gt;\r\n&lt;/ol&gt;\r\n\r\n','\r',char(13)),'\n',char(10)),NULL,' html testing',0,'','2021-12-01 10:15');
INSERT INTO articles VALUES(24,replace(replace('This has unmarked linefeeds.\r\n&lt;br&gt; This is the second line.\r\n&lt;br&gt; The third line is here.\r\n&lt;p&gt;\r\nThere is a blank line above this line using p tag.\r\n','\r',char(13)),'\n',char(10)),NULL,'html test 2',2,'','2021-12-01 11:17');
INSERT INTO articles VALUES(25,replace(replace('&lt;code&gt;\r\nThis has unmarked linefeeds.\r\nThis is the second line.\r\nThe third line is here.\r\n\r\nThere is a blank line above this line.\r\n&lt;/code&gt;\r\n','\r',char(13)),'\n',char(10)),NULL,' html test 3 with code tag',0,'','2021-12-01 11:19');
INSERT INTO articles VALUES(26,replace(replace(' &lt;pre&gt;\r\nThis has unmarked linefeeds.\r\nThis is the second line.\r\nThe third line is here.\r\n\r\n&lt;em&gt;There is a blank line above this line.&lt;/em&gt;\r\n&lt;/pre&gt;\r\n&lt;pre&gt;','\r',char(13)),'\n',char(10)),NULL,' html test with',0,'','2021-12-01 11:26');
INSERT INTO articles VALUES(27,replace(replace('testing which characters are encoded\r\n!@#$%^\r\n&amp;*()-\r\n_=+[]\r\n;:''&quot;\|','\r',char(13)),'\n',char(10)),NULL,'charset',0,'','2021-12-01 11:28');
INSERT INTO articles VALUES(28,replace(replace(' jump back to home?\r\n&lt;br&gt;modified on 1/5\r\n&lt;br&gt;around 15:40.\r\n&lt;br&gt;around 15:41.','\r',char(13)),'\n',char(10)),NULL,'test modified',0,'2022-01-05 22:42','2021-12-01 11:36');
INSERT INTO articles VALUES(29,' will it jump?',NULL,'<del> jump ?</del>',0,'','2021-12-01 11:36');
INSERT INTO articles VALUES(30,' jump!',NULL,'<del> try again</del>',0,'','2021-12-01 11:37');
INSERT INTO articles VALUES(31,' blank body 1',NULL,'<del> title 31</del>',0,'','2021-12-01 11:39');
INSERT INTO articles VALUES(32,'body 2',NULL,'<del> blank 2</del>',0,'','2021-12-01 11:42');
INSERT INTO articles VALUES(33,' body 33',NULL,'title 33',2,'2022-01-21 22:57','2021-12-01 11:42');
INSERT INTO articles VALUES(34,replace(replace('The rev 4 was stored in Agile and review directory on 11/23.\r\nIt was stored in the secured site for NASA on 12/1.','\r',char(13)),'\n',char(10)),NULL,'NASA FPGA checklist',0,'','2021-12-01 12:00');
INSERT INTO articles VALUES(35,'test 13',NULL,'test 13',0,'','2021-12-01 15:26');
INSERT INTO articles VALUES(36,replace(replace('&quot;Reason Code for Change&quot; is needed now.\r\n&lt;br&gt;&lt;br&gt;\r\nUse &quot;planned_maturity&quot; for initial releases.\r\n&lt;br&gt;\r\n#:agile #:code_for_change','\r',char(13)),'\n',char(10)),NULL,'Agile release change coversheet',0,'2022-01-14 14:51','2021-12-02 19:04');
INSERT INTO articles VALUES(37,'test after a_date and a_time are combined into a_datetime in database.',NULL,'blog dev - table fields',0,'','2021-12-03 14:46');
INSERT INTO articles VALUES(38,replace(replace('&lt;tag&gt;FPGA&lt;/tag&gt;&lt;tag&gt;Synplify&lt;/tag&gt;\r\n&lt;tag&gt;constraints&lt;/tag&gt;\r\n&lt;br&gt;\r\n&lt;w3-blue&gt;From &quot;Synplify Pro for Microsemi Edition Reference Manual, January 2014&quot; &lt;/w3-blue&gt;\r\n&lt;p&gt;\r\nThe term timing exceptions refers to the false path, max path delay, and\r\nmulticycle path timing constraints. When the tool encounters conflicts in the\r\nway timing exceptions are specified through the constraint file, the software\r\nuses a set priority to resolve these conflicts. Conflict resolution is categorized\r\ninto four levels, meaning that there are four different tiers at which conflicting\r\nconstraints can occur, with one being the highest. The table below summarizes\r\nconflict resolution for constraints. The sections following the table\r\nprovide more details on how conflicts can occur and examples of how they are\r\nresolved.\r\n&lt;p&gt;\r\n&lt;table border=&quot;1px&quot;&gt;\r\n&lt;tr&gt;\r\n&lt;th&gt;Conflict Level\r\n&lt;th&gt;Constraint Conflict\r\n&lt;th&gt; Priority \r\n&lt;th&gt;For Details, see ...\r\n&lt;/tr&gt;\r\n&lt;tr&gt;\r\n&lt;td&gt;1\r\n&lt;td&gt; Different timing\r\nexceptions set on the\r\nsame object.\r\n&lt;td&gt;&lt;ol&gt;&lt;li&gt; False Path\r\n&lt;li&gt; Path Delay\r\n&lt;li&gt;Multi-cycle Path\r\n&lt;/ol&gt;\r\n&lt;td&gt;Conflicting Timing\r\nExceptions, on\r\npage 207.\r\n&lt;/tr&gt;\r\n&lt;tr&gt;\r\n&lt;td&gt; 2\r\n&lt;td&gt; Timing exceptions of\r\nthe same constraint\r\ntype, using different\r\nsemantics\r\n(from/to/through).\r\n&lt;td&gt;&lt;ol&gt;\r\n&lt;li&gt;From\r\n&lt;li&gt;To\r\n&lt;li&gt;Through\r\n&lt;/ol&gt;\r\n&lt;td&gt;Same Constraint\r\nType with Different\r\nSemantics, on\r\npage 208.\r\n&lt;/tr&gt;\r\n&lt;tr&gt;\r\n&lt;td&gt;3 \r\n&lt;td&gt;Timing exceptions of\r\nthe same constraint\r\ntype using the same\r\nsemantic, but set on\r\ndifferent objects.\r\n&lt;td&gt;&lt;ol&gt;\r\n&lt;li&gt; Ports/Instances/Pins\r\n&lt;li&gt; Clocks\r\n&lt;/ol&gt;\r\n&lt;td&gt;\r\nSame Constraint\r\nand Semantics with\r\nDifferent Objects,\r\non page 209.\r\n&lt;/tr&gt;\r\n&lt;tr&gt;\r\n&lt;td&gt;4\r\n&lt;td&gt; Identical timing\r\nconstraints, except\r\nconstraint values differ.\r\n&lt;td&gt;Tightest, or most\r\nconstricting constraint.\r\n&lt;td&gt;Identical\r\nConstraints with\r\nDifferent Values, on\r\npage 209.\r\n&lt;/tr&gt;\r\n&lt;/table&gt;\r\n&lt;p&gt;\r\nIn addition to the four levels of conflict resolution for timing exceptions, there\r\nare priorities for the way the tool handles multiple I/O delays set on the same\r\nport and implicit and explicit false path constraints. For information on\r\nresolving these types of conflicts, see Priority of Multiple I/O Constraints, on\r\npage 177 and Priority of False Path Constraints, on page 197.','\r',char(13)),'\n',char(10)),NULL,'Conflict Resolution for Timing Exceptions',0,'','2021-12-06 16:12');
INSERT INTO articles VALUES(39,replace(replace('&lt;tag&gt;constraint&lt;/tag&gt;&lt;tag&gt;timing&lt;/tag&gt;&lt;tag&gt;synplify&lt;/tag&gt;\r\n&lt;br&gt;\r\nThese constraints in Synplify FDC needs -clock and -max parameters.&lt;br&gt;\r\nOtherwise, they pass through Synplify''s constraint checker for &quot;unconstrained IOs&quot; but might not generate constraints in the output SDC file !!\r\n','\r',char(13)),'\n',char(10)),NULL,'Timing constraints - set_input_delay and set_output_delay',0,'','2021-12-07 15:39');
INSERT INTO articles VALUES(40,replace(replace('&lt;table border=&quot;1px&quot;&gt;										\r\n&lt;tr&gt;	&lt;th&gt;	hdr1&lt;th&gt;	&lt;th&gt;	&lt;th&gt;	&lt;th&gt;	&lt;th&gt;hdr 10\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	data 71&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;\r\n&lt;tr&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;	&lt;td&gt;data 99	&lt;td&gt;\r\n&lt;/table&gt;										\r\n','\r',char(13)),'\n',char(10)),NULL,'table test',0,'','2021-12-07 17:47');
INSERT INTO articles VALUES(41,replace(replace('An output cell itself has a significant delay in RTAX STD parts.\r\n&lt;pre&gt;\r\n 8ma  Low slew - 16.898ns\r\n12ma Low slew - 14.244ns\r\n16ma Low slew - 12.642ns\r\n 8ma  High slew -  5.072ns\r\n16ma High slew -  3.877ns\r\n&lt;/pre&gt;\r\n\r\n#:RTAX','\r',char(13)),'\n',char(10)),NULL,'RTAX IO delay',0,'2022-01-14 14:34','2021-12-08 17:17');
INSERT INTO articles VALUES(42,replace(replace('Figuring out if another sdc with \r\n&lt;code&gt;set_max_delay\r\n&lt;/code&gt;\r\nwould work...\r\n','\r',char(13)),'\n',char(10)),NULL,'direct sdc',0,'','2021-12-08 21:32');
INSERT INTO articles VALUES(43,replace(replace('Fixed FRD Appendix A.\r\nFixed the VHDL code.\r\n\r\nChanged MPC_RLY_STAT_ACM to MPC_RLY_STAT for board trace name\r\nChanged ctm_spare2_in to mpc_spare_in \r\nAdded ut699e_sram4_cs_n and ut699e_sram4_oe_n\r\n\r\n\r\n','\r',char(13)),'\n',char(10)),NULL,'Fixed missing IOs and wrong names',0,'','2021-12-09 10:56');
INSERT INTO articles VALUES(44,replace(replace('When this message shows up,\r\n&lt;pre&gt;\r\n    WARNING: Attempt to start the Wind/U registry appears to have failed.\r\n&lt;/pre&gt;\r\nrun,\r\n&lt;pre&gt;\r\n    actel_wuclean_all\r\n&lt;/pre&gt;\r\n\r\n&lt;br&gt; #:actel #:libero #:actel_wuclean ','\r',char(13)),'\n',char(10)),NULL,'Microsemi Designer failed to start',0,'2022-01-20 11:35','2021-12-14 16:01');
INSERT INTO articles VALUES(45,replace(replace('These often happens because ctm_en is 0. Not FPGA issues.\r\n\r\n&lt;pre&gt;\r\nuvm_test_top.env_h.sb.sb_tlm [sb_base] CTM_LVDT_RD_RDY error. Got 0x0, expected 0x1\r\nuvm_test_top.env_h.sb.sb_tlm [sb_base] CTM_CRYO_DI_RD_RDY error. Got 0x0, expected 0x1\r\n&lt;/pre&gt;\r\n\r\n&lt;p&gt;#:verification #:RST','\r',char(13)),'\n',char(10)),NULL,'RST FPGA verification errors',0,'','2021-12-16 12:33');
INSERT INTO articles VALUES(46,replace(replace('This type of errors occurred just before a reset (of some kind) is applied. I don''t think it is an FPGA issue.\r\n\r\n&lt;pre&gt;\r\nbasic_tlm_test_0006.log:# UVM_ERROR @ 532651692ns: uvm_test_top.env_h.sb.sb_mpc [sb_mpc] Got \r\nADC_MUX_ENABLE_CHANGE transaction with no state change: ADC_MUX_ENABLE_CHANGE: \r\nstart=532651692ns, mux_sel=0x0, mux_en_n=1, lvdt_ab=0\r\n&lt;/pre&gt;\r\n\r\nAs a side note, ut699e_rst_n is asserted 1 clock cycle before sys_rst_n is asserted on warm resets. I don''t believe this is an issue.\r\n\r\n&lt;p&gt;#:verification #:RST','\r',char(13)),'\n',char(10)),NULL,'RST FPGA verification errors 2',0,'','2021-12-16 12:37');
INSERT INTO articles VALUES(47,replace(replace('These errors are due to the score board checking the states on UT699E_RST_N goes low. SYS_RST is asserted 1 clock cycle after. Also, it seems that the scoreboard is checking the states on signal edges where assignments sequence is random. So it does not cause a UVM error about a half of times that a reset caused rcs_pwr_off_trg_n to go low.\r\n\r\n&lt;pre&gt;\r\nreset_test_0001.log:# UVM_ERROR @ 7039192ns: reporter [TB reset check2]  tb_vif.rcs_pwr_vif.rcs_pwr_off_trg_n invalid reset value 0x1\r\nreset_test_0001.log:# UVM_ERROR @ 7039192ns: reporter [TB reset check2]  tb_adc_clk invalid reset value 0x1\r\n&lt;/pre&gt;\r\n\r\n&lt;p&gt;#:verification #:RST','\r',char(13)),'\n',char(10)),NULL,'RST FPGA verification errors 3',0,'','2021-12-17 09:01');
INSERT INTO articles VALUES(48,replace(replace('TLM_EN is checked at the beginning of each device read. TLM_EN is deasserted after a read started in this case.\r\n&lt;pre&gt;\r\nbasic_tlm_test_0021.log:# UVM_ERROR @ 345867341ns: uvm_test_top.env_h.sb.sb_tlm [sb_tlm] Thermal Telemetry sampled without TLM_EN set\r\n&lt;/pre&gt;\r\n\r\n#:verification #:RST','\r',char(13)),'\n',char(10)),NULL,'RST FPGA verification errors 4',0,'','2021-12-17 09:21');
INSERT INTO articles VALUES(49,replace(replace('13.1 has a spreadsheet attachment. Some of its questions are not answered.\r\n&lt;p&gt;\r\nChris questions if all of resets (global and local) replicated signals were tested/verified. This cannot be done through simulation because RTL sim does not have any knowledge of synthesis replicated paths. Gate level sim takes way too long.\r\nHopefully, test guys add tests to confirm outputs and registers get back to their default values when a (warm) reset is applied.\r\n&lt;p&gt;\r\nrefer to email under &quot;FLT MCB board test of FPGA reset Output line behaviour...&quot; from Andy Rudeen on 12/17/2021','\r',char(13)),'\n',char(10)),NULL,'NASA''s FPGA Checklist - answers',0,'','2021-12-18 14:49');
INSERT INTO articles VALUES(50,replace(replace('Where should it be or what variable needs to point to?\r\n','\r',char(13)),'\n',char(10)),NULL,'Perl module Clone.pm',0,'','2021-12-18 15:09');
INSERT INTO articles VALUES(51,replace(replace('With Designer Smart Timer,\r\nTools - Options - Advanced tab\r\nEnsure &quot;Include inter-clock domains&quot; is unchecked\r\nEnsure &quot;Break paths at asynchronous pins&quot; is unchecked\r\nCheck each clock domains reg to reg\r\nDid any green check marks turn to red Xs\r\nIf yes then determine if OK\r\nMay be OK for assertion to take more than 1 clock cycle provided negation takes less (:CLK to :CLR/PRE paths)\r\n\r\nTo filter out POR paths, set mf_por_n as a false path.\r\n','\r',char(13)),'\n',char(10)),NULL,'FPGA Long Asynchronous Path',0,'','2021-12-21 14:31');
INSERT INTO articles VALUES(52,replace(replace('In order to install a  perl module in user space, run from the source\r\n  perl Makefile.PL INSTALL_BASE=$HOME/usr\r\n  make\r\n  make install\r\n','\r',char(13)),'\n',char(10)),NULL,'Perl modules user installation',0,'','2021-12-22 10:25');
INSERT INTO articles VALUES(53,replace(replace('Use # and : to make a tag &lt;br&gt;\r\n#:tag_test &lt;br&gt;\r\nThis article has a Hashcolon to embed a keyword.\r\n','\r',char(13)),'\n',char(10)),NULL,'test keyword (#:)',0,'','2022-01-03 14:06');
INSERT INTO articles VALUES(66,replace(replace(' #:tag_test #:delete_this_test\r\n&lt;br&gt;\r\nThis is 12th article that has a Tag of &quot;test_tag&quot;. ','\r',char(13)),'\n',char(10)),NULL,'<del>tag test 12</del>',0,'','2022-01-03 15:09');
INSERT INTO articles VALUES(67,replace(replace(' #:tag_test \r\nThis is 13th article that has a Tag of &quot;test_tag&quot;. ','\r',char(13)),'\n',char(10)),NULL,'<del>tag test 13</del>',0,'','2022-01-03 15:59');
INSERT INTO articles VALUES(68,replace(replace('#:delete_this_test This is 14th article that has a Tag of &quot;test_tag&quot;. \r\n#:tag3\r\n&lt;br&gt;modified 1/5 15:45','\r',char(13)),'\n',char(10)),NULL,'<del>tag test 14</del>',0,'2022-01-05 15:46','2022-01-03 16:00');
INSERT INTO articles VALUES(69,replace(replace('&lt;del&gt;\r\n&lt;pre&gt;\r\nsome text \r\nanother line\r\n3rd line\r\n4th\r\n&lt;/pre&gt;\r\n&lt;/del&gt;','\r',char(13)),'\n',char(10)),NULL,'add test',2,'2022-01-22 13:52','2022-01-04 11:38');
INSERT INTO articles VALUES(70,replace(replace('#:tag\r\n#tag3\r\n#tag4\r\ntest ','\r',char(13)),'\n',char(10)),NULL,'<del>tag test 5</del>',0,'','2022-01-04 15:03');
INSERT INTO articles VALUES(71,replace(replace('#:tag\r\n#:test_tag\r\nhello\r\n\r\n#:hello','\r',char(13)),'\n',char(10)),NULL,'tag test 6',2,'2022-01-22 00:21','2022-01-04 15:04');
INSERT INTO articles VALUES(72,replace(replace('#:hello\r\n\r\ntext is added.','\r',char(13)),'\n',char(10)),NULL,'more tag test',2,'2022-01-21 18:40','2022-01-04 15:16');
INSERT INTO articles VALUES(73,replace(replace('#:tag_test &lt;br&gt;\r\nfollowed up article 53.\r\n','\r',char(13)),'\n',char(10)),NULL,'test keyword (#:)',2,'2022-01-21 18:39','2022-01-05 16:48');
INSERT INTO articles VALUES(83,replace(replace('#:notebook &lt;br&gt;\r\nAdded tag column &lt;ul&gt;\r\n&lt;li&gt;Added expandable tag list\r\n&lt;li&gt;Added title list\r\n&lt;/ul&gt;\r\nAdded &quot;follow up&quot; to follow up an article with the same title. It adds a link back and the same tags when committed.','\r',char(13)),'\n',char(10)),NULL,'notebook development',0,'','2022-01-05 17:19');
INSERT INTO articles VALUES(84,replace(replace('#:notebook &lt;br&gt;\r\nnotebook_1.1.tar.bz2 created and uploaded','\r',char(13)),'\n',char(10)),NULL,'notebook development',0,'','2022-01-05 17:35');
INSERT INTO articles VALUES(85,replace(replace('#:notebook &lt;br&gt;\r\nver 1.2 \r\nTitle list is Collapseable.','\r',char(13)),'\n',char(10)),NULL,'notebook development',0,'','2022-01-06 17:46');
INSERT INTO articles VALUES(86,replace(replace('&lt;pre&gt;\r\n#:notebook \r\n&lt;b&gt;Usage&lt;/b&gt;\r\n  Start server\r\n      php -S localhost:50273 &gt; /dev/null 2&gt;&amp;1\r\n  \r\n  Connect\r\n      http:/localhost:50273/index.php\r\n&lt;/pre&gt;\r\n','\r',char(13)),'\n',char(10)),NULL,'notebook usage',0,'2022-01-07 08:38','2022-01-07 08:37');
INSERT INTO articles VALUES(87,replace(replace('#:RST #:cell_placement &lt;br&gt;\r\n&lt;pre class=&quot;nb-arial&quot;&gt;\r\nRTAX Cell placement\r\n\r\n	Locking the placement of all logic\r\n	Unlocking the XOR, AND2A and CM8 cells\r\n	Manually moving the XOR, AND2A and CM8 cells to empty cells within 20 or so rows and columns of the CLKINT buffer at the bottom middle of the die\r\n	Locking placement of these XOR, AND2A and CM8 cells\r\n	Re-routing with incremental routing\r\n	Visually verify the clk16mhz signal into the CLKINT is now short and co-located around the CLKITN buffer\r\n	Recheck timing\r\n&lt;/prel&gt;','\r',char(13)),'\n',char(10)),NULL,'FPGA Cell Placement',0,'2022-01-07 11:14','2022-01-07 09:45');
INSERT INTO articles VALUES(88,replace(replace('#:RST #:cell_placement #:clocks&lt;br&gt;\r\nChris Dailey said a pre-clock path (path to clkint input) with long vertical paths (can be seen in Chip Planner) may cause some signal integrity issues. &lt;br&gt;\r\nKeep cells on a pre-clock path in bottom rows near clkint.\r\n','\r',char(13)),'\n',char(10)),NULL,'FPGA Cell Placement',0,'2022-01-07 14:49','2022-01-07 14:48');
INSERT INTO articles VALUES(89,replace(replace('Changed password on\r\n&lt;ul&gt;\r\n&lt;li&gt; windows network\r\n&lt;li&gt; unix nodes\r\n&lt;li&gt; samba server\r\n&lt;li&gt; agile\r\n\r\n&lt;/ul&gt;\r\n','\r',char(13)),'\n',char(10)),NULL,'password change',0,'','2022-01-10 10:21');
INSERT INTO articles VALUES(90,replace(replace('#:RST #:verification\r\n&lt;br&gt;\r\nTo compile FPGA and Testbench, run   &lt;pre&gt;\r\n    make RTAX=1 ISRAM_MODEL=1 FAST_SIM=1 2&gt;&amp;1 \r\n&lt;/pre&gt;\r\n','\r',char(13)),'\n',char(10)),NULL,'RST Verification Compile',1,'2022-01-10 17:05','2022-01-10 17:05');
INSERT INTO articles VALUES(91,replace(replace('use \r\n&lt;pre&gt;\r\n  clusterpasswd \r\n&lt;/pre&gt;\r\nto change the password in fpganodes.\r\n\r\n#:password #:cssh #:fpganodes','\r',char(13)),'\n',char(10)),NULL,'change the password in fpganodes',0,'','2022-01-13 11:21');
INSERT INTO articles VALUES(92,replace(replace('#:flicker_noise \r\n&lt;br&gt;\r\nADC runs at 800MHz in Transport Layer Mode to make 3.2G samples / sec.\r\n&lt;br&gt;\r\nThe ADC has 16 channels and we use only 8, DA0-3 DB0-3.\r\n&lt;br&gt;\r\nSquare each data and add them up.\r\n','\r',char(13)),'\n',char(10)),NULL,'Flicker Noise Measurement Basic Info',0,'2022-01-14 11:44','2022-01-14 11:34');
INSERT INTO articles VALUES(93,replace(replace('#:notebook &lt;br&gt;\r\nver 1.2.1 &lt;br&gt;\r\nShows the current title index in title list and tag index in tag list&lt;br&gt;\r\nAdded hyper-link in title index in title list &lt;br&gt;\r\n','\r',char(13)),'\n',char(10)),NULL,'notebook development',0,'','2022-01-14 15:26');
INSERT INTO articles VALUES(94,'For #:vivado, use lsfrun.',NULL,'vivado invocation',0,'','2022-01-20 08:59');
INSERT INTO articles VALUES(95,replace(replace('Try\r\n&lt;pre&gt;\r\nmodule avail\r\nmodule help\r\n&lt;/pre&gt;\r\n&lt;br&gt;\r\n#:module #:environment #:FPGA\r\n','\r',char(13)),'\n',char(10)),NULL,'environment setup for tools',0,'','2022-01-20 09:01');
INSERT INTO articles VALUES(96,'follow-up #:test',NULL,'test --Microsemi Designer failed to start',2,'2022-01-21 18:29','2022-01-20 11:19');
INSERT INTO articles VALUES(97,replace(replace('Try actel_wuclean individually, if there is a running process that you do not want to terminate.\r\n&lt;pre&gt;\r\nssh fpganode1-vlx actel_wuclean\r\n&lt;/pre&gt;\r\nOr, run actel_wuclean after ssh into each node.\r\n\r\n&lt;br&gt;\r\n #:actel #:libero #:actel_wuclean ','\r',char(13)),'\n',char(10)),NULL,'Microsemi Designer failed to start',0,'2022-01-20 11:34','2022-01-20 11:26');
INSERT INTO articles VALUES(98,replace(replace('From Dan Dietrich, &lt;br&gt;\r\n\r\nThe issue is the Libero tools run on a Windows emulation layer called Wind/u.  The windu* tasks get started and continue to run after your job ends.  Most of the time that is fine but sometimes the windu tasks get lost, consume a bunch of CPU time and not work correctly but do not actually crash.  That??s what was happening today.  I ended up looking for the processes and their PIDs with the ??pstree?? command as shown below.  Then I used the kill command to terminate those PIDs.\r\n&lt;br&gt;\r\n&lt;pre&gt;\r\n[fpgaadm@fpganode2-vlx ~]$ pstree -u tisogai -p\r\nwindu_registryd(113744)\u2500\u252c\u2500{windu_registry}(113745)\r\n                        \u251c\u2500{windu_registry}(113746)\r\n                        \u2514\u2500{windu_registry}(113747)\r\n\r\nwindu_scmd50(113862)\u2500\u252c\u2500{windu_scmd50}(113867)\r\n                     \u2514\u2500{windu_scmd50}(113869)\r\n\r\n[fpgaadm@fpganode2-vlx ~]$ kill -9 113744 113862\r\n&lt;/pre&gt;\r\n&lt;br&gt;\r\n#:actel #:libero #:actel_wuclean\r\n\r\n','\r',char(13)),'\n',char(10)),NULL,'Microsemi Designer failed to start',0,'2022-01-20 13:34','2022-01-20 11:32');
INSERT INTO articles VALUES(99,'asdfljllll',NULL,'sndf3',2,'','2022-01-21 23:18');
INSERT INTO articles VALUES(100,'test test',NULL,'snv 7',2,'','2022-01-21 23:35');
INSERT INTO articles VALUES(101,replace(replace('#:tag_test &lt;br&gt;\r\nfollow-up tested','\r',char(13)),'\n',char(10)),NULL,'tag test 13',2,'2022-01-22 00:14','2022-01-21 23:53');
INSERT INTO articles VALUES(102,replace(replace('#:tag_test &lt;br&gt;\r\nfollowed 101','\r',char(13)),'\n',char(10)),NULL,'tag test 13',2,'2022-01-22 00:14','2022-01-21 23:56');
INSERT INTO articles VALUES(103,replace(replace('GLiNet 750m &lt;br&gt;\r\n192.168.8.1 can be connected through its own GL750 wifi.\r\n&lt;br&gt;\r\n#:router #:glinet','\r',char(13)),'\n',char(10)),NULL,'GLiNet router',0,'','2022-01-22 13:55');
INSERT INTO articles VALUES(104,replace(replace('#:network #:linux \r\n&lt;br&gt;\r\nInstall r8125 driver\r\n\r\n','\r',char(13)),'\n',char(10)),NULL,'network connection',0,'','2022-02-28 22:31');
INSERT INTO articles VALUES(105,'Ace0=bass',NULL,'EDA Playground',0,'','2022-03-07 15:03');
INSERT INTO articles VALUES(106,replace(replace('ice@273K\r\n#:uvm','\r',char(13)),'\n',char(10)),NULL,'verification academy',0,'','2022-03-08 08:41');
INSERT INTO articles VALUES(107,replace(replace('Use simple-scan to scan &lt;br&gt;\r\nUse pdftk with encrypt_128bit to encrypt &lt;br&gt;\r\n\r\n#:pdf #:scan #:encrypt\r\n','\r',char(13)),'\n',char(10)),NULL,'Scan',0,'2022-03-08 22:06','2022-03-08 22:05');
INSERT INTO articles VALUES(108,replace(replace('#:printer #:ubuntu #:linux\r\n&lt;br&gt;\r\nPrinter setup \r\n&lt;br&gt;\r\nsudo apt-get install printer-driver-gutenprint\r\n&lt;br&gt;\r\nThen, add the printer using printer configuration','\r',char(13)),'\n',char(10)),NULL,'printer on ubuntu',0,'','2022-03-30 17:29');
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('keywords',50);
INSERT INTO sqlite_sequence VALUES('article_links',27);
INSERT INTO sqlite_sequence VALUES('file_links',0);
INSERT INTO sqlite_sequence VALUES('keyword_links',124);
INSERT INTO sqlite_sequence VALUES('articles',108);
COMMIT;
