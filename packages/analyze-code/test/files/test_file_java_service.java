package com.example.service;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import com.example.model.User;
import com.example.model.DatabaseConnection;
import com.example.utils.JsonHelper;
import com.example.scripts.BashExecutor;

/**
 * Test service class for analyzer validation
 * Cross-references: User.java, DatabaseConnection.java, JsonHelper.js, execute_tests.sh
 */
public class TestService {
    private DatabaseConnection dbConnection;
    private JsonHelper jsonHelper;
    private BashExecutor bashExecutor;
    
    private static final String CONFIG_FILE = "config.yaml";
    private static final int DEFAULT_TIMEOUT = 30;
    
    /**
     * Constructor with dependency injection
     */
    public TestService(DatabaseConnection connection) {
        this.dbConnection = connection;
        this.jsonHelper = new JsonHelper();
        this.bashExecutor = new BashExecutor();
    }
    
    /**
     * Complex method for complexity analysis testing
     */
    public List<User> processUsers(Map<String, Object> criteria) {
        List<User> result = new ArrayList<>();
        
        if (criteria == null || criteria.isEmpty()) {
            throw new IllegalArgumentException("Criteria cannot be null or empty");
        }
        
        try {
            // Nested loops for complexity testing
            for (String key : criteria.keySet()) {
                Object value = criteria.get(key);
                
                if (value instanceof String) {
                    String strValue = (String) value;
                    if (strValue.length() > 10) {
                        for (int i = 0; i < strValue.length(); i++) {
                            if (Character.isDigit(strValue.charAt(i))) {
                                // Complex nested logic
                                result.addAll(searchUsersByNumericCriteria(key, strValue.substring(i)));
                                break;
                            }
                        }
                    }
                } else if (value instanceof Integer) {
                    result.addAll(searchUsersByIntCriteria(key, (Integer) value));
                }
            }
            
            // Call external script for additional processing
            String scriptResult = bashExecutor.executeScript("process_users.sh", result.size());
            
            // Process JSON configuration
            Map<String, Object> config = jsonHelper.loadConfigFromYaml(CONFIG_FILE);
            
        } catch (Exception e) {
            throw new RuntimeException("Error processing users: " + e.getMessage(), e);
        }
        
        return result;
    }
    
    private List<User> searchUsersByNumericCriteria(String key, String value) {
        return dbConnection.query("SELECT * FROM users WHERE " + key + " LIKE ?", "%" + value + "%");
    }
    
    private List<User> searchUsersByIntCriteria(String key, Integer value) {
        return dbConnection.query("SELECT * FROM users WHERE " + key + " = ?", value);
    }
    
    // Getter and setter methods
    public DatabaseConnection getDbConnection() {
        return dbConnection;
    }
    
    public void setDbConnection(DatabaseConnection dbConnection) {
        this.dbConnection = dbConnection;
    }
}