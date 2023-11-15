package example.webapp.one;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class CustomServletContextListener implements ServletContextListener {

    private static final Logger LOG = LoggerFactory.getLogger(CustomServletContextListener.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOG.info("CustomServletContextListener initialized");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOG.info("CustomServletContextListener destroyed");
    }
}
