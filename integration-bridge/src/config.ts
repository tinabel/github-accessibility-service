/**
 * Unified Configuration System for Accessibility Integration
 *
 * This module provides a centralized configuration system that works across
 * both the accessibility-scraper and mcp-accessibility-evaluator components.
 */

import fs from "fs-extra";
import path from "path";
import { config as dotenvConfig } from "dotenv";

export interface IntegrationConfig {
  // Scraper Configuration
  scraper: {
    wcagBaseUrl: string;
    maxConcurrentRequests: number;
    requestDelayMs: number;
    timeoutMs: number;
    userAgent: string;
    headless: boolean;
    puppeteerArgs: string[];
  };

  // Evaluator Configuration
  evaluator: {
    wcagLevel: "A" | "AA" | "AAA";
    strictMode: boolean;
    includeCodeExamples: boolean;
    minImpactLevel: "minor" | "moderate" | "serious" | "critical";
    enableAxeCore: boolean;
    enableARIAValidation: boolean;
  };

  // Integration Configuration
  integration: {
    outputDir: string;
    cacheDir: string;
    updateInterval: number; // hours
    autoUpdate: boolean;
    enableCaching: boolean;
    cacheExpiration: number; // hours
  };

  // MCP Server Configuration
  mcp: {
    serverName: string;
    version: string;
    enableEnhancedMode: boolean;
    enableDocumentationFetching: boolean;
    enableComprehensiveAnalysis: boolean;
  };

  // Logging Configuration
  logging: {
    level: "error" | "warn" | "info" | "debug";
    enableFileLogging: boolean;
    logFile: string;
    enableConsoleLogging: boolean;
  };
}

export class ConfigManager {
  private static instance: ConfigManager;
  private config: IntegrationConfig;
  private configPath: string;
  private envPath: string;

  private constructor() {
    this.configPath = path.join(
      process.cwd(),
      "accessibility-integration.config.json"
    );
    this.envPath = path.join(process.cwd(), ".env");
    this.config = this.getDefaultConfig();
    this.loadConfig();
  }

  public static getInstance(): ConfigManager {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    return ConfigManager.instance;
  }

  /**
   * Get the current configuration
   */
  public getConfig(): IntegrationConfig {
    return { ...this.config };
  }

  /**
   * Update configuration
   */
  public async updateConfig(
    updates: Partial<IntegrationConfig>
  ): Promise<void> {
    this.config = { ...this.config, ...updates };
    await this.saveConfig();
  }

  /**
   * Load configuration from files and environment
   */
  private loadConfig(): void {
    // Load environment variables
    if (fs.existsSync(this.envPath)) {
      dotenvConfig({ path: this.envPath });
    }

    // Load from config file
    if (fs.existsSync(this.configPath)) {
      try {
        const fileConfig = fs.readJsonSync(this.configPath);
        this.config = { ...this.config, ...fileConfig };
      } catch (error) {
        console.warn("Failed to load config file:", error);
      }
    }

    // Override with environment variables
    this.loadFromEnvironment();
  }

  /**
   * Load configuration from environment variables
   */
  private loadFromEnvironment(): void {
    // Scraper environment variables
    if (process.env.WCAG_BASE_URL) {
      this.config.scraper.wcagBaseUrl = process.env.WCAG_BASE_URL;
    }
    if (process.env.MAX_CONCURRENT_REQUESTS) {
      this.config.scraper.maxConcurrentRequests = parseInt(
        process.env.MAX_CONCURRENT_REQUESTS
      );
    }
    if (process.env.REQUEST_DELAY_MS) {
      this.config.scraper.requestDelayMs = parseInt(
        process.env.REQUEST_DELAY_MS
      );
    }
    if (process.env.TIMEOUT_MS) {
      this.config.scraper.timeoutMs = parseInt(process.env.TIMEOUT_MS);
    }
    if (process.env.HEADLESS !== undefined) {
      this.config.scraper.headless = process.env.HEADLESS === "true";
    }

    // Evaluator environment variables
    if (process.env.WCAG_LEVEL) {
      this.config.evaluator.wcagLevel = process.env.WCAG_LEVEL as
        | "A"
        | "AA"
        | "AAA";
    }
    if (process.env.STRICT_MODE !== undefined) {
      this.config.evaluator.strictMode = process.env.STRICT_MODE === "true";
    }
    if (process.env.MIN_IMPACT_LEVEL) {
      this.config.evaluator.minImpactLevel = process.env.MIN_IMPACT_LEVEL as
        | "minor"
        | "moderate"
        | "serious"
        | "critical";
    }
    if (process.env.ENABLE_AXE_CORE !== undefined) {
      this.config.evaluator.enableAxeCore =
        process.env.ENABLE_AXE_CORE === "true";
    }

    // Integration environment variables
    if (process.env.OUTPUT_DIR) {
      this.config.integration.outputDir = process.env.OUTPUT_DIR;
    }
    if (process.env.CACHE_DIR) {
      this.config.integration.cacheDir = process.env.CACHE_DIR;
    }
    if (process.env.UPDATE_INTERVAL) {
      this.config.integration.updateInterval = parseInt(
        process.env.UPDATE_INTERVAL
      );
    }
    if (process.env.AUTO_UPDATE !== undefined) {
      this.config.integration.autoUpdate = process.env.AUTO_UPDATE === "true";
    }

    // MCP environment variables
    if (process.env.MCP_SERVER_NAME) {
      this.config.mcp.serverName = process.env.MCP_SERVER_NAME;
    }
    if (process.env.ENABLE_ENHANCED_MODE !== undefined) {
      this.config.mcp.enableEnhancedMode =
        process.env.ENABLE_ENHANCED_MODE === "true";
    }

    // Logging environment variables
    if (process.env.LOG_LEVEL) {
      this.config.logging.level = process.env.LOG_LEVEL as
        | "error"
        | "warn"
        | "info"
        | "debug";
    }
    if (process.env.ENABLE_FILE_LOGGING !== undefined) {
      this.config.logging.enableFileLogging =
        process.env.ENABLE_FILE_LOGGING === "true";
    }
    if (process.env.LOG_FILE) {
      this.config.logging.logFile = process.env.LOG_FILE;
    }
  }

  /**
   * Save configuration to file
   */
  private async saveConfig(): Promise<void> {
    try {
      await fs.ensureDir(path.dirname(this.configPath));
      await fs.writeJson(this.configPath, this.config, { spaces: 2 });
    } catch (error) {
      console.error("Failed to save config:", error);
    }
  }

  /**
   * Get default configuration
   */
  private getDefaultConfig(): IntegrationConfig {
    return {
      scraper: {
        wcagBaseUrl: "https://www.w3.org/WAI/WCAG21/",
        maxConcurrentRequests: 5,
        requestDelayMs: 1000,
        timeoutMs: 30000,
        userAgent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        headless: true,
        puppeteerArgs: [
          "--no-sandbox",
          "--disable-setuid-sandbox",
          "--disable-dev-shm-usage",
          "--disable-accelerated-2d-canvas",
          "--no-first-run",
          "--no-zygote",
          "--disable-gpu",
          "--disable-web-security",
          "--disable-features=VizDisplayCompositor",
          "--single-process",
        ],
      },
      evaluator: {
        wcagLevel: "AA",
        strictMode: false,
        includeCodeExamples: true,
        minImpactLevel: "moderate",
        enableAxeCore: true,
        enableARIAValidation: true,
      },
      integration: {
        outputDir: "./output",
        cacheDir: "./cache",
        updateInterval: 24,
        autoUpdate: true,
        enableCaching: true,
        cacheExpiration: 168, // 7 days
      },
      mcp: {
        serverName: "accessibility-evaluator",
        version: "1.0.0",
        enableEnhancedMode: true,
        enableDocumentationFetching: true,
        enableComprehensiveAnalysis: true,
      },
      logging: {
        level: "info",
        enableFileLogging: true,
        logFile: "./logs/accessibility-integration.log",
        enableConsoleLogging: true,
      },
    };
  }

  /**
   * Validate configuration
   */
  public validateConfig(): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Validate scraper config
    if (!this.config.scraper.wcagBaseUrl) {
      errors.push("WCAG base URL is required");
    }
    if (this.config.scraper.maxConcurrentRequests < 1) {
      errors.push("Max concurrent requests must be at least 1");
    }
    if (this.config.scraper.requestDelayMs < 0) {
      errors.push("Request delay must be non-negative");
    }
    if (this.config.scraper.timeoutMs < 1000) {
      errors.push("Timeout must be at least 1000ms");
    }

    // Validate evaluator config
    if (!["A", "AA", "AAA"].includes(this.config.evaluator.wcagLevel)) {
      errors.push("WCAG level must be A, AA, or AAA");
    }
    if (
      !["minor", "moderate", "serious", "critical"].includes(
        this.config.evaluator.minImpactLevel
      )
    ) {
      errors.push(
        "Min impact level must be minor, moderate, serious, or critical"
      );
    }

    // Validate integration config
    if (this.config.integration.updateInterval < 1) {
      errors.push("Update interval must be at least 1 hour");
    }
    if (this.config.integration.cacheExpiration < 1) {
      errors.push("Cache expiration must be at least 1 hour");
    }

    // Validate logging config
    if (
      !["error", "warn", "info", "debug"].includes(this.config.logging.level)
    ) {
      errors.push("Log level must be error, warn, info, or debug");
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  /**
   * Create example configuration files
   */
  public async createExampleFiles(): Promise<void> {
    // Create example .env file
    const envExample = `# Accessibility Integration Configuration

# Scraper Configuration
WCAG_BASE_URL=https://www.w3.org/WAI/WCAG21/
MAX_CONCURRENT_REQUESTS=5
REQUEST_DELAY_MS=1000
TIMEOUT_MS=30000
HEADLESS=true

# Evaluator Configuration
WCAG_LEVEL=AA
STRICT_MODE=false
MIN_IMPACT_LEVEL=moderate
ENABLE_AXE_CORE=true

# Integration Configuration
OUTPUT_DIR=./output
CACHE_DIR=./cache
UPDATE_INTERVAL=24
AUTO_UPDATE=true

# MCP Configuration
MCP_SERVER_NAME=accessibility-evaluator
ENABLE_ENHANCED_MODE=true

# Logging Configuration
LOG_LEVEL=info
ENABLE_FILE_LOGGING=true
LOG_FILE=./logs/accessibility-integration.log
`;

    await fs.writeFile(".env.example", envExample);

    // Create example config file
    await fs.writeJson(
      "accessibility-integration.config.example.json",
      this.config,
      { spaces: 2 }
    );
  }

  /**
   * Reset to default configuration
   */
  public async resetToDefaults(): Promise<void> {
    this.config = this.getDefaultConfig();
    await this.saveConfig();
  }
}

// Export singleton instance
export const configManager = ConfigManager.getInstance();
