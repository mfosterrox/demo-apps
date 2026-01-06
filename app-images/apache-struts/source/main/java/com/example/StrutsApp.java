package com.example;

import com.opensymphony.xwork2.ActionSupport;
import javax.servlet.http.HttpServletRequest;
import org.apache.struts2.interceptor.ServletRequestAware;

public class StrutsApp extends ActionSupport implements ServletRequestAware {
    
    private static final long serialVersionUID = 1L;
    private HttpServletRequest request;
    private String message;
    
    public String execute() {
        // Vulnerable code demonstrating CVE-2017-5638
        // This is intentionally vulnerable for demonstration purposes
        message = "Apache Struts CVE-2017-5638 Demo Application";
        return SUCCESS;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    @Override
    public void setServletRequest(HttpServletRequest request) {
        this.request = request;
    }
    
    public HttpServletRequest getRequest() {
        return request;
    }
}

