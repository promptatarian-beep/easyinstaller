#!/usr/bin/env python3
"""
Tests for easyinstaller build system
"""

import unittest
import tempfile
import json
from pathlib import Path
from build import EasyInstallerBuilder


class TestEasyInstallerBuilder(unittest.TestCase):
    
    def setUp(self):
        """Create a temporary config for testing"""
        self.test_dir = tempfile.TemporaryDirectory()
        self.config_file = Path(self.test_dir.name) / "test_config.yaml"
        self.output_dir = Path(self.test_dir.name) / "build"
        
        # Write minimal test config
        config_yaml = """
project_name: Test App
project_version: 1.0.0
project_author: Test
project_website: https://test.com
platforms:
  - linux
  - windows
  - mac
copy_files: []
"""
        self.config_file.write_text(config_yaml)
    
    def tearDown(self):
        """Clean up temporary files"""
        self.test_dir.cleanup()
    
    def test_load_config(self):
        """Test configuration loading"""
        builder = EasyInstallerBuilder(self.config_file, self.output_dir)
        config = builder.load_config()
        
        self.assertEqual(config['project_name'], 'Test App')
        self.assertEqual(config['project_version'], '1.0.0')
        self.assertIn('linux', config['platforms'])
    
    def test_validate_config(self):
        """Test configuration validation"""
        builder = EasyInstallerBuilder(self.config_file, self.output_dir)
        builder.load_config()
        
        # Should not raise exception
        builder.validate_config()
    
    def test_create_build_dirs(self):
        """Test build directory creation"""
        builder = EasyInstallerBuilder(self.config_file, self.output_dir)
        builder.load_config()
        builder.create_build_dirs()
        
        self.assertTrue((self.output_dir / 'linux').exists())
        self.assertTrue((self.output_dir / 'windows').exists())
        self.assertTrue((self.output_dir / 'mac').exists())
    
    def test_build_creates_metadata(self):
        """Test that build creates BUILD_INFO.json"""
        builder = EasyInstallerBuilder(self.config_file, self.output_dir)
        builder.build()
        
        build_info_file = self.output_dir / 'BUILD_INFO.json'
        self.assertTrue(build_info_file.exists())
        
        with open(build_info_file) as f:
            build_info = json.load(f)
        
        self.assertEqual(build_info['project_name'], 'Test App')
        self.assertEqual(build_info['project_version'], '1.0.0')
    
    def test_build_generates_installers(self):
        """Test that build generates platform-specific installers"""
        builder = EasyInstallerBuilder(self.config_file, self.output_dir)
        builder.build()
        
        # Check Linux installer
        self.assertTrue((self.output_dir / 'linux' / 'install.sh').exists())
        
        # Check Windows installer
        self.assertTrue((self.output_dir / 'windows' / 'installer.nsi').exists())
        
        # Check macOS installer
        self.assertTrue((self.output_dir / 'mac' / 'install.sh').exists())


if __name__ == '__main__':
    unittest.main()
