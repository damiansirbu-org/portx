#!/usr/bin/env python3
"""
JSON Helper module for cross-language data processing
Cross-references: TestService.java, config.yaml, chart/values.yaml, tests.js
"""

import json
import yaml
import os
import sys
import logging
from typing import Dict, List, Any, Optional, Union
from dataclasses import dataclass
from pathlib import Path
import subprocess


@dataclass
class ConfigurationData:
    """Data class for configuration management"""
    database_url: str
    api_timeout: int
    debug_enabled: bool
    features: List[str]


class JsonHelper:
    """
    Comprehensive JSON and YAML processing helper
    Supports multiple formats and cross-references with other components
    """
    
    def __init__(self, config_dir: Optional[str] = None):
        self.config_dir = config_dir or os.path.dirname(__file__)
        self.logger = self._setup_logging()
        self.supported_formats = ['json', 'yaml', 'yml']
        
    def _setup_logging(self) -> logging.Logger:
        """Setup logging configuration"""
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.INFO)
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
            
        return logger
    
    def load_config_from_yaml(self, filename: str) -> Dict[str, Any]:
        """
        Load configuration from YAML file with complex validation
        Cross-reference: config.yaml, chart/values.yaml
        """
        file_path = Path(self.config_dir) / filename
        
        try:
            if not file_path.exists():
                raise FileNotFoundError(f"Configuration file not found: {file_path}")
                
            with open(file_path, 'r', encoding='utf-8') as file:
                config_data = yaml.safe_load(file)
                
            # Complex validation logic for analyzer testing
            if not isinstance(config_data, dict):
                raise ValueError("Configuration must be a dictionary")
                
            # Nested validation with multiple conditions
            required_keys = ['database', 'api', 'features']
            for key in required_keys:
                if key not in config_data:
                    self.logger.warning(f"Missing required key: {key}")
                    config_data[key] = self._get_default_config(key)
                else:
                    # Complex nested validation
                    if key == 'database' and isinstance(config_data[key], dict):
                        for db_key in ['url', 'timeout']:
                            if db_key not in config_data[key]:
                                config_data[key][db_key] = self._get_default_db_config(db_key)
                                
            return config_data
            
        except yaml.YAMLError as e:
            self.logger.error(f"YAML parsing error: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Configuration loading error: {e}")
            raise
    
    def process_json_data(self, data: Union[str, Dict, List]) -> Dict[str, Any]:
        """
        Process JSON data with complex transformation logic
        Cross-reference: TestService.java processing methods
        """
        result = {
            'processed_at': self._get_timestamp(),
            'original_type': type(data).__name__,
            'transformations': []
        }
        
        try:
            if isinstance(data, str):
                # Try to parse as JSON string
                parsed_data = json.loads(data)
                result['transformations'].append('json_parse')
                data = parsed_data
                
            if isinstance(data, dict):
                # Complex dictionary processing
                result['data'] = self._process_dictionary(data)
                result['transformations'].append('dict_processing')
            elif isinstance(data, list):
                # Complex list processing
                result['data'] = self._process_list(data)
                result['transformations'].append('list_processing')
            else:
                result['data'] = {'value': str(data)}
                result['transformations'].append('string_conversion')
                
        except json.JSONDecodeError as e:
            self.logger.error(f"JSON parsing error: {e}")
            result['error'] = str(e)
        except Exception as e:
            self.logger.error(f"Data processing error: {e}")
            result['error'] = str(e)
            
        return result
    
    def _process_dictionary(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Complex dictionary processing with nested logic"""
        processed = {}
        
        for key, value in data.items():
            # Multi-level processing based on key patterns
            if key.startswith('db_'):
                processed[key] = self._process_database_config(value)
            elif key.startswith('api_'):
                processed[key] = self._process_api_config(value)
            elif isinstance(value, dict):
                # Recursive processing for nested dictionaries
                processed[key] = self._process_dictionary(value)
            elif isinstance(value, list):
                # Process lists with complex logic
                processed[key] = [self._transform_list_item(item, i) 
                                for i, item in enumerate(value)]
            else:
                processed[key] = value
                
        return processed
    
    def _process_list(self, data: List[Any]) -> List[Any]:
        """Complex list processing with filtering and transformation"""
        processed = []
        
        for i, item in enumerate(data):
            if isinstance(item, dict):
                # Complex filtering based on dictionary content
                if 'enabled' in item and not item['enabled']:
                    continue
                if 'priority' in item:
                    item['processing_order'] = i
                processed.append(self._process_dictionary(item))
            elif isinstance(item, str):
                # String transformation with multiple conditions
                if item.startswith('#'):
                    continue  # Skip comments
                processed.append(self._transform_string(item))
            else:
                processed.append(item)
                
        return processed
    
    def _process_database_config(self, value: Any) -> Dict[str, Any]:
        """Process database-specific configuration"""
        if isinstance(value, str):
            return {
                'connection_string': value,
                'parsed': True,
                'type': 'database_url'
            }
        return {'value': value, 'type': 'database_other'}
    
    def _process_api_config(self, value: Any) -> Dict[str, Any]:
        """Process API-specific configuration"""
        if isinstance(value, (int, float)):
            return {
                'timeout': value,
                'parsed': True,
                'type': 'api_timeout'
            }
        return {'value': value, 'type': 'api_other'}
    
    def _transform_list_item(self, item: Any, index: int) -> Any:
        """Transform individual list items with complex logic"""
        if isinstance(item, str):
            return f"{index}_{item.upper()}"
        elif isinstance(item, dict):
            item['list_index'] = index
            return item
        return item
    
    def _transform_string(self, value: str) -> str:
        """Complex string transformation"""
        transformations = [
            lambda s: s.strip(),
            lambda s: s.replace('${config_dir}', self.config_dir),
            lambda s: s.replace('${timestamp}', self._get_timestamp())
        ]
        
        for transform in transformations:
            value = transform(value)
            
        return value
    
    def _get_default_config(self, key: str) -> Any:
        """Get default configuration values"""
        defaults = {
            'database': {'url': 'localhost:5432', 'timeout': 30},
            'api': {'timeout': 60, 'retries': 3},
            'features': ['logging', 'monitoring']
        }
        return defaults.get(key, {})
    
    def _get_default_db_config(self, key: str) -> Any:
        """Get default database configuration values"""
        defaults = {
            'url': 'localhost:5432',
            'timeout': 30
        }
        return defaults.get(key)
    
    def _get_timestamp(self) -> str:
        """Get current timestamp string"""
        from datetime import datetime
        return datetime.now().isoformat()
    
    def execute_bash_script(self, script_name: str, *args) -> Dict[str, Any]:
        """
        Execute bash script and return results
        Cross-reference: execute_tests.sh, process_users.sh
        """
        script_path = Path(self.config_dir) / 'scripts' / script_name
        
        try:
            cmd = ['bash', str(script_path)] + list(map(str, args))
            result = subprocess.run(
                cmd, 
                capture_output=True, 
                text=True, 
                timeout=60
            )
            
            return {
                'success': result.returncode == 0,
                'stdout': result.stdout.strip(),
                'stderr': result.stderr.strip(),
                'return_code': result.returncode,
                'script': script_name,
                'args': list(args)
            }
            
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'error': 'Script execution timeout',
                'script': script_name
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'script': script_name
            }


def main():
    """Main function for testing"""
    helper = JsonHelper()
    
    # Test YAML loading
    try:
        config = helper.load_config_from_yaml('config.yaml')
        print(f"Configuration loaded: {json.dumps(config, indent=2)}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test JSON processing
    test_data = {
        'db_url': 'postgresql://localhost:5432/test',
        'api_timeout': 30,
        'features': ['auth', 'logging', {'name': 'monitoring', 'enabled': True}]
    }
    
    processed = helper.process_json_data(test_data)
    print(f"Processed data: {json.dumps(processed, indent=2)}")


if __name__ == '__main__':
    main()