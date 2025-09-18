/**
 * JavaScript test utilities and cross-platform integration
 * Cross-references: TestService.java, json_helper.py, config.yaml, execute_tests.sh
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

/**
 * Test configuration manager with complex logic
 */
class TestConfigManager {
    constructor(configDir = __dirname) {
        this.configDir = configDir;
        this.cache = new Map();
        this.listeners = new Set();
        this.initialized = false;
    }

    /**
     * Initialize configuration with complex async operations
     * Cross-reference: json_helper.py load_config_from_yaml
     */
    async initialize() {
        if (this.initialized) {
            return;
        }

        try {
            // Complex initialization with multiple async operations
            const configPromises = [
                this.loadYamlConfig('config.yaml'),
                this.loadYamlConfig('chart/values.yaml'),
                this.loadJsonConfig('package.json')
            ];

            const [mainConfig, chartConfig, packageConfig] = await Promise.allSettled(configPromises);

            // Complex error handling and data merging
            const mergedConfig = this.mergeConfigurations([
                this.handlePromiseResult(mainConfig, 'main'),
                this.handlePromiseResult(chartConfig, 'chart'),
                this.handlePromiseResult(packageConfig, 'package')
            ]);

            this.cache.set('merged_config', mergedConfig);
            this.initialized = true;

            // Notify all listeners
            this.notifyListeners('initialized', mergedConfig);

        } catch (error) {
            throw new Error(`Configuration initialization failed: ${error.message}`);
        }
    }

    /**
     * Load YAML configuration with complex validation
     */
    async loadYamlConfig(filename) {
        const filePath = path.join(this.configDir, filename);
        
        try {
            if (!fs.existsSync(filePath)) {
                throw new Error(`Configuration file not found: ${filePath}`);
            }

            const fileContent = fs.readFileSync(filePath, 'utf8');
            const config = yaml.load(fileContent);

            // Complex validation logic
            if (typeof config !== 'object' || config === null) {
                throw new Error('Invalid configuration format');
            }

            // Multi-level validation based on filename
            if (filename.includes('values.yaml')) {
                return this.validateHelmValues(config);
            } else if (filename.includes('config.yaml')) {
                return this.validateMainConfig(config);
            }

            return config;

        } catch (error) {
            console.error(`Error loading YAML config ${filename}:`, error.message);
            throw error;
        }
    }

    /**
     * Load JSON configuration
     */
    async loadJsonConfig(filename) {
        const filePath = path.join(this.configDir, filename);
        
        try {
            if (!fs.existsSync(filePath)) {
                return {};
            }

            const fileContent = fs.readFileSync(filePath, 'utf8');
            return JSON.parse(fileContent);

        } catch (error) {
            console.error(`Error loading JSON config ${filename}:`, error.message);
            return {};
        }
    }

    /**
     * Validate Helm values with complex logic
     */
    validateHelmValues(config) {
        const requiredSections = ['image', 'service', 'ingress'];
        const validated = { ...config };

        // Complex validation with nested logic
        for (const section of requiredSections) {
            if (!validated[section]) {
                validated[section] = this.getDefaultHelmSection(section);
            } else {
                // Deep validation for each section
                switch (section) {
                    case 'image':
                        validated[section] = this.validateImageSection(validated[section]);
                        break;
                    case 'service':
                        validated[section] = this.validateServiceSection(validated[section]);
                        break;
                    case 'ingress':
                        validated[section] = this.validateIngressSection(validated[section]);
                        break;
                }
            }
        }

        return validated;
    }

    /**
     * Validate main configuration
     */
    validateMainConfig(config) {
        const requiredKeys = ['database', 'api', 'features'];
        const validated = { ...config };

        // Complex nested validation
        for (const key of requiredKeys) {
            if (!validated[key]) {
                validated[key] = this.getDefaultConfigSection(key);
            } else if (typeof validated[key] === 'object') {
                // Recursive validation for nested objects
                validated[key] = this.validateNestedConfig(validated[key], key);
            }
        }

        return validated;
    }

    /**
     * Complex nested configuration validation
     */
    validateNestedConfig(config, parentKey) {
        const validated = { ...config };

        // Complex branching logic for different config types
        if (parentKey === 'database') {
            const dbDefaults = { url: 'localhost:5432', timeout: 30, poolSize: 10 };
            for (const [key, defaultValue] of Object.entries(dbDefaults)) {
                if (validated[key] === undefined) {
                    validated[key] = defaultValue;
                }
            }
        } else if (parentKey === 'api') {
            const apiDefaults = { timeout: 60, retries: 3, rateLimit: 100 };
            for (const [key, defaultValue] of Object.entries(apiDefaults)) {
                if (validated[key] === undefined) {
                    validated[key] = defaultValue;
                }
            }
        }

        return validated;
    }

    /**
     * Execute external Python script for cross-language integration
     */
    async executePythonScript(scriptName, ...args) {
        const scriptPath = path.join(this.configDir, `${scriptName}.py`);
        
        try {
            const command = `python3 "${scriptPath}" ${args.join(' ')}`;
            const { stdout, stderr } = await execAsync(command);

            if (stderr && !stderr.includes('warning')) {
                throw new Error(`Python script error: ${stderr}`);
            }

            // Try to parse JSON output
            try {
                return JSON.parse(stdout.trim());
            } catch {
                return { output: stdout.trim(), raw: true };
            }

        } catch (error) {
            throw new Error(`Failed to execute Python script ${scriptName}: ${error.message}`);
        }
    }

    /**
     * Execute bash script for testing integration
     */
    async executeBashScript(scriptName, ...args) {
        const scriptPath = path.join(this.configDir, 'scripts', scriptName);
        
        try {
            const command = `bash "${scriptPath}" ${args.join(' ')}`;
            const { stdout, stderr } = await execAsync(command);

            return {
                success: true,
                stdout: stdout.trim(),
                stderr: stderr.trim(),
                script: scriptName,
                args: args
            };

        } catch (error) {
            return {
                success: false,
                error: error.message,
                script: scriptName,
                args: args
            };
        }
    }

    /**
     * Complex configuration merging with conflict resolution
     */
    mergeConfigurations(configs) {
        const merged = {};
        
        // Complex merging logic with priority handling
        for (let i = 0; i < configs.length; i++) {
            const config = configs[i];
            if (config && typeof config === 'object') {
                for (const [key, value] of Object.entries(config)) {
                    if (merged[key] && typeof merged[key] === 'object' && typeof value === 'object') {
                        // Deep merge for nested objects
                        merged[key] = this.deepMerge(merged[key], value);
                    } else {
                        // Simple assignment with priority (later configs override)
                        merged[key] = value;
                    }
                }
            }
        }

        return merged;
    }

    /**
     * Deep merge utility function
     */
    deepMerge(target, source) {
        const result = { ...target };
        
        for (const [key, value] of Object.entries(source)) {
            if (value && typeof value === 'object' && !Array.isArray(value)) {
                result[key] = this.deepMerge(result[key] || {}, value);
            } else {
                result[key] = value;
            }
        }

        return result;
    }

    /**
     * Handle Promise.allSettled results
     */
    handlePromiseResult(result, type) {
        if (result.status === 'fulfilled') {
            return result.value;
        } else {
            console.warn(`Failed to load ${type} configuration:`, result.reason.message);
            return {};
        }
    }

    /**
     * Event listener management
     */
    addListener(callback) {
        this.listeners.add(callback);
    }

    removeListener(callback) {
        this.listeners.delete(callback);
    }

    notifyListeners(event, data) {
        for (const callback of this.listeners) {
            try {
                callback(event, data);
            } catch (error) {
                console.error('Listener error:', error);
            }
        }
    }

    // Helper methods for default configurations
    getDefaultHelmSection(section) {
        const defaults = {
            image: { repository: 'nginx', tag: 'latest', pullPolicy: 'IfNotPresent' },
            service: { type: 'ClusterIP', port: 80 },
            ingress: { enabled: false, annotations: {}, hosts: [] }
        };
        return defaults[section] || {};
    }

    getDefaultConfigSection(section) {
        const defaults = {
            database: { url: 'localhost:5432', timeout: 30 },
            api: { timeout: 60, retries: 3 },
            features: ['logging', 'monitoring']
        };
        return defaults[section] || {};
    }

    validateImageSection(image) {
        return {
            repository: image.repository || 'nginx',
            tag: image.tag || 'latest',
            pullPolicy: image.pullPolicy || 'IfNotPresent',
            ...image
        };
    }

    validateServiceSection(service) {
        return {
            type: service.type || 'ClusterIP',
            port: service.port || 80,
            targetPort: service.targetPort || service.port || 80,
            ...service
        };
    }

    validateIngressSection(ingress) {
        return {
            enabled: ingress.enabled !== undefined ? ingress.enabled : false,
            annotations: ingress.annotations || {},
            hosts: Array.isArray(ingress.hosts) ? ingress.hosts : [],
            ...ingress
        };
    }
}

/**
 * Test runner with complex scenario handling
 */
class TestRunner {
    constructor(configManager) {
        this.configManager = configManager;
        this.testResults = new Map();
    }

    async runAllTests() {
        const tests = [
            'testConfigurationLoading',
            'testCrossLanguageIntegration',
            'testBashScriptExecution',
            'testYamlProcessing'
        ];

        const results = [];
        
        for (const testName of tests) {
            try {
                const result = await this[testName]();
                results.push({ test: testName, success: true, result });
            } catch (error) {
                results.push({ test: testName, success: false, error: error.message });
            }
        }

        return results;
    }

    async testConfigurationLoading() {
        await this.configManager.initialize();
        const config = this.configManager.cache.get('merged_config');
        
        if (!config || typeof config !== 'object') {
            throw new Error('Configuration loading failed');
        }

        return { configKeys: Object.keys(config), loaded: true };
    }

    async testCrossLanguageIntegration() {
        try {
            const result = await this.configManager.executePythonScript('json_helper', 'test');
            return { pythonIntegration: true, result };
        } catch (error) {
            return { pythonIntegration: false, error: error.message };
        }
    }

    async testBashScriptExecution() {
        try {
            const result = await this.configManager.executeBashScript('execute_tests.sh', 'validate');
            return { bashIntegration: true, result };
        } catch (error) {
            return { bashIntegration: false, error: error.message };
        }
    }

    async testYamlProcessing() {
        const testData = {
            image: { repository: 'test', tag: '1.0' },
            service: { type: 'NodePort', port: 8080 }
        };

        const validated = this.configManager.validateHelmValues(testData);
        
        return {
            validated: true,
            originalKeys: Object.keys(testData),
            validatedKeys: Object.keys(validated)
        };
    }
}

// Export for testing
module.exports = {
    TestConfigManager,
    TestRunner
};

// Main execution for standalone testing
async function main() {
    try {
        const configManager = new TestConfigManager();
        const testRunner = new TestRunner(configManager);
        
        const results = await testRunner.runAllTests();
        console.log('Test Results:', JSON.stringify(results, null, 2));
        
    } catch (error) {
        console.error('Test execution failed:', error);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}