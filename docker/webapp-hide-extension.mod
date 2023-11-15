[description]
Web app module

[exec]
-Xmx512m

[libs]
# provides a custom StatusListener implementation
lib/simple-logback-extension.jar

[ini]
--jpms
# Hide CustomStatusListener from webapps so they can not use it
jetty.webapp.addServerClasses+=,example.logback.extension.

[jpms]
add-modules: java.sql