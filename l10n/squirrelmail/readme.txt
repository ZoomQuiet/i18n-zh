Translation statistics:
        http://l10n-stats.squirrelmail.org/HEAD/

SquirrelMail trunk:
    http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/trunk/squirrelmail
    http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/trunk/locales/

    (56%) 847 translated messages, 357 fuzzy translations, 307 untranslated messages.

    wget -O squirrelmail.pot http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/trunk/squirrelmail/po/squirrelmail.pot
    msgmerge --no-wrap -o squirrelmail_new.po squirrelmail.po squirrelmail.pot
    mv -f squirrelmail_new.po squirrelmail.po
    msgfmt --statistics -c squirrelmail.po

SquirrelMail 1.4.x:
    http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/branches/SM-1_4-STABLE/squirrelmail
    http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/branches/SM-1_4_13/locales

    (71%) 815 translated messages, 147 fuzzy translations, 186 untranslated messages.

    wget -O squirrelmail-1.4.x.pot http://squirrelmail.svn.sourceforge.net/svnroot/squirrelmail/branches/SM-1_4-STABLE/squirrelmail/po/squirrelmail.pot
    msgmerge --no-wrap -o squirrelmail-1.4.x_new.po squirrelmail-1.4.x.po squirrelmail-1.4.x.pot
    mv -f squirrelmail-1.4.x_new.po squirrelmail-1.4.x.po
    msgfmt --statistics -c squirrelmail-1.4.x.po
