This project demonstrates a classloading issue in Jetty 12 when using Jetty module `logging-logback` together with 
web applications that also bundle Logback.

### Requirements

- Docker needs to be installed.
- Ports 8080 and 9999 are available

### Usage

To run the project use 
```
./docker/run.sh <MODULE> <WEBAPP> <OPTIONAL STARTJAR PARAMS>

MODULE: webapp.mod | webapp-hide-extension.mod
WEBAPP: webapp-1 | webapp-2 | webapp-3

Example: 
./docker/run.sh webapp.mod webapp-1
./docker/run.sh webapp-hide-extension.mod webapp-3 --list-config
```
If the `docker` executable requires `sudo` then the script should be run using `sudo`.

### Modules

Regardless of the module name below, inside the docker image the module is always named `webapp.mod`. The `run.sh` 
script renames the module to keep the `Dockerfile` simple.

#### webapp.mod

This module enables JPMS mode in Jetty, provides some JVM and JPMS parameters and adds a Logback extension library. 
The Logback extension library contains a custom implementation of `ch.qos.logback.core.status.StatusListener` named 
`example.logback.extension.CustomStatusListener`. 

#### webapp-hide-extension.mod

This module is the same as `webapp.mod` but in addition adds the package `example.logback.extension` to Jetty server 
classes. This should hide `example.logback.extension.CustomStatusListener` from web application. Thus it should not be 
possible to use that class unless the web application adds a dependency to the same logback extension library.

### Webapps

All webapps have a custom `ServletContextListener` that logs `context initialized` and `context destroyed` using Logback.

#### webapp-1

- DOES NOT provide its own `logback.xml`
- DOES NOT have a dependency to the logback extension library (thus the library is not in `WEB-INF/lib`)

Expected result:
- The web application should complain that it can not find any `logback.xml`

Actual result:
- The web application finds `/var/lib/jetty/resources/logback.xml`
- The `WebAppClassLoader` is able to load `example.logback.extension.CustomStatusListener` (even if `webapp-hide-extension.mod` has been used)
- Logback throws `ch.qos.logback.core.util.IncompatibleClassException` because `ch.qos.logback.core.status.StatusListener` and `example.logback.extension.CustomStatusListener` are loaded by different classloaders

#### webapp-2

- DOES provide its own `logback.xml` which references `example.logback.extension.CustomStatusListener`
- DOES NOT have a dependency to the logback extension library (thus the library is not in `WEB-INF/lib`)

Expected result:
- The web application should only find its own `logback.xml`
- If `webapp-hide-extension.mod` is used, Logback provided by the web application should not be able to load class `example.logback.extension.CustomStatusListener`

Actual result:
- The web application finds its own `logback.xml` and `/var/lib/jetty/resources/logback.xml`
- The `WebAppClassLoader` is able to load `example.logback.extension.CustomStatusListener`
- Logback throws `ch.qos.logback.core.util.IncompatibleClassException` because `ch.qos.logback.core.status.StatusListener` and `example.logback.extension.CustomStatusListener` are loaded by different classloaders


#### webapp-3

- DOES provide its own `logback.xml` which references `example.logback.extension.CustomStatusListener`
- DOES have a dependency to the logback extension library (thus the library is in `WEB-INF/lib`)

Expected result:
- The web application should only find its own `logback.xml`

Actual result:
- The web application finds its own `logback.xml` and `/var/lib/jetty/resources/logback.xml`

### Exception being thrown

```
ERROR in ch.qos.logback.core.model.processor.StatusListenerModelHandler - Could not create an StatusListener of type [example.logback.extension.CustomStatusListener]. ch.qos.logback.core.util.IncompatibleClassException
        at ch.qos.logback.core.util.IncompatibleClassException
        at      at ch.qos.logback.core.util.OptionHelper.instantiateByClassNameAndParameter(OptionHelper.java:58)
        at      at ch.qos.logback.core.util.OptionHelper.instantiateByClassName(OptionHelper.java:44)
        at      at ch.qos.logback.core.util.OptionHelper.instantiateByClassName(OptionHelper.java:33)
        at      at ch.qos.logback.core.model.processor.StatusListenerModelHandler.handle(StatusListenerModelHandler.java:46)
```

Using `./run.sh webapp-hide-extension.mod webapp-2 -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=9999` the JVM waits for a debug connection on `localhost:9999` before starting jetty.