#!/usr/bin/env node

/**
 * Integration Bridge between accessibility-scraper and mcp-accessibility-evaluator
 *
 * This module provides seamless integration between the two components:
 * 1. Uses accessibility-scraper to fetch live WCAG documentation
 * 2. Updates mcp-accessibility-evaluator with fresh accessibility rules
 * 3. Provides unified CLI interface for both components
 * 4. Enables comprehensive accessibility analysis pipeline
 */

import { Command } from "commander";
import chalk from "chalk";
import ora from "ora";
import fs from "fs-extra";
import path from "path";

// Import from accessibility-scraper
import { PuppeteerScrapingService } from "../accessibility-scraper/src/services/scraper.js";
import { ScrapeCommand } from "../accessibility-scraper/src/commands/scrape.js";
import { MapCommand } from "../accessibility-scraper/src/commands/map.js";
import { ExtractCommand } from "../accessibility-scraper/src/commands/extract.js";
import { SearchCommand } from "../accessibility-scraper/src/commands/search.js";
import { DefaultServiceContainer } from "../accessibility-scraper/src/core/container.js";

// Import from mcp-accessibility-evaluator
import { AccessibilityEvaluator } from "../mcp-accessibility-evaluator/src/accessibility-evaluator.js";
import { WCAGComplianceChecker } from "../mcp-accessibility-evaluator/src/wcag-compliance-checker.js";
import { ARIAValidator } from "../mcp-accessibility-evaluator/src/aria-validator.js";
import { DocumentationFetcher } from "../mcp-accessibility-evaluator/src/documentation-fetcher.js";

interface IntegrationConfig {
  wcagBaseUrl: string;
  outputDir: string;
  cacheDir: string;
  updateInterval: number; // hours
  autoUpdate: boolean;
}

interface ScrapedWCAGData {
  guidelines: Array<{ id: string; title: string; description?: string }>;
  successCriteria: Array<{
    id: string;
    title: string;
    level: string;
    description?: string;
  }>;
  techniques: Array<{ id: string; title: string; description?: string }>;
  lastUpdated: Date;
}

class AccessibilityIntegrationBridge {
  private config: IntegrationConfig;
  private scraper: PuppeteerScrapingService;
  private evaluator: AccessibilityEvaluator;
  private wcagChecker: WCAGComplianceChecker;
  private ariaValidator: ARIAValidator;
  private docFetcher: DocumentationFetcher;
  private container: DefaultServiceContainer;

  constructor(config: IntegrationConfig) {
    this.config = config;
    this.scraper = new PuppeteerScrapingService();
    this.evaluator = new AccessibilityEvaluator();
    this.wcagChecker = new WCAGComplianceChecker();
    this.ariaValidator = new ARIAValidator();
    this.docFetcher = new DocumentationFetcher();
    this.container = new DefaultServiceContainer();
  }

  /**
   * Initialize the integration bridge
   */
  async initialize(): Promise<void> {
    const spinner = ora(
      "Initializing accessibility integration bridge..."
    ).start();

    try {
      // Ensure output directories exist
      await fs.ensureDir(this.config.outputDir);
      await fs.ensureDir(this.config.cacheDir);

      // Initialize documentation fetcher
      await this.docFetcher.initialize();

      spinner.succeed("Integration bridge initialized successfully!");
    } catch (error) {
      spinner.fail("Failed to initialize integration bridge");
      throw error;
    }
  }

  /**
   * Fetch and update WCAG documentation using the scraper
   */
  async updateWCAGDocumentation(): Promise<ScrapedWCAGData> {
    const spinner = ora("Fetching latest WCAG documentation...").start();

    try {
      // Map WCAG website structure
      spinner.text = "Mapping WCAG website structure...";
      const urls = await this.scraper.mapWCAGSite(this.config.wcagBaseUrl, {
        maxDepth: 2,
        maxLinks: 100,
        allowedDomains: ["w3.org"],
        followExternalLinks: false,
      });

      // Scrape key WCAG pages
      spinner.text = "Scraping WCAG guidelines and success criteria...";
      const scrapedData: ScrapedWCAGData = {
        guidelines: [],
        successCriteria: [],
        techniques: [],
        lastUpdated: new Date(),
      };

      // Scrape guidelines
      const guidelinesUrl = urls.find((url) => url.includes("guidelines"));
      if (guidelinesUrl) {
        const result = await this.scraper.scrapePage(guidelinesUrl);
        if (result.success) {
          scrapedData.guidelines = this.extractGuidelines(result.content);
        }
      }

      // Scrape success criteria
      const criteriaUrl = urls.find((url) => url.includes("success-criteria"));
      if (criteriaUrl) {
        const result = await this.scraper.scrapePage(criteriaUrl);
        if (result.success) {
          scrapedData.successCriteria = this.extractSuccessCriteria(
            result.content
          );
        }
      }

      // Save scraped data
      const dataPath = path.join(this.config.cacheDir, "wcag-data.json");
      await fs.writeJson(dataPath, scrapedData, { spaces: 2 });

      spinner.succeed(
        `Successfully updated WCAG documentation (${scrapedData.guidelines.length} guidelines, ${scrapedData.successCriteria.length} criteria)`
      );

      return scrapedData;
    } catch (error) {
      spinner.fail("Failed to update WCAG documentation");
      throw error;
    }
  }

  /**
   * Extract guidelines from scraped content
   */
  private extractGuidelines(
    content: string
  ): Array<{ id: string; title: string; description?: string }> {
    const guidelines: Array<{
      id: string;
      title: string;
      description?: string;
    }> = [];
    const lines = content.split("\n");

    for (const line of lines) {
      const match = line.match(/(\d+\.\d+)\s+(.+)/);
      if (match && match[1] && match[2]) {
        guidelines.push({
          id: match[1],
          title: match[2].trim(),
        });
      }
    }

    return guidelines;
  }

  /**
   * Extract success criteria from scraped content
   */
  private extractSuccessCriteria(
    content: string
  ): Array<{ id: string; title: string; level: string; description?: string }> {
    const criteria: Array<{
      id: string;
      title: string;
      level: string;
      description?: string;
    }> = [];
    const lines = content.split("\n");

    for (const line of lines) {
      const match = line.match(/(\d+\.\d+\.\d+)\s+(.+)/);
      if (match && match[1] && match[2]) {
        // Determine level based on content
        let level = "A";
        if (line.toLowerCase().includes("aa")) level = "AA";
        if (line.toLowerCase().includes("aaa")) level = "AAA";

        criteria.push({
          id: match[1],
          title: match[2].trim(),
          level,
        });
      }
    }

    return criteria;
  }

  /**
   * Perform comprehensive accessibility analysis
   */
  async analyzeAccessibility(html: string, url?: string): Promise<any> {
    const spinner = ora(
      "Performing comprehensive accessibility analysis..."
    ).start();

    try {
      // Run evaluation
      spinner.text = "Running accessibility evaluation...";
      const evaluationResult = await this.evaluator.evaluateHTML(html);

      // Check WCAG compliance
      spinner.text = "Checking WCAG compliance...";
      const complianceReport = this.wcagChecker.evaluateCompliance(
        evaluationResult,
        "AA"
      );

      // Validate ARIA
      spinner.text = "Validating ARIA usage...";
      const ariaResult = this.ariaValidator.validate(html);

      // Generate comprehensive report
      const report = {
        timestamp: new Date(),
        url: url || "local-content",
        evaluation: evaluationResult,
        compliance: complianceReport,
        aria: ariaResult,
        summary: {
          totalIssues: evaluationResult.summary.totalIssues,
          complianceLevel: complianceReport.level,
          meetsAA: complianceReport.level >= "AA",
          ariaIssues: ariaResult.issues.length,
        },
      };

      // Save report
      const reportPath = path.join(
        this.config.outputDir,
        `accessibility-report-${Date.now()}.json`
      );
      await fs.writeJson(reportPath, report, { spaces: 2 });

      spinner.succeed(
        `Accessibility analysis completed! Found ${report.summary.totalIssues} issues.`
      );

      return report;
    } catch (error) {
      spinner.fail("Failed to perform accessibility analysis");
      throw error;
    }
  }

  /**
   * Clean up resources
   */
  async cleanup(): Promise<void> {
    await this.scraper.close();
    await this.container.dispose();
  }
}

// CLI Setup
const program = new Command();

program
  .name("accessibility-integration")
  .description(
    "Integration bridge between accessibility-scraper and mcp-accessibility-evaluator"
  )
  .version("1.0.0");

// Configuration
const defaultConfig: IntegrationConfig = {
  wcagBaseUrl: "https://www.w3.org/WAI/WCAG21/",
  outputDir: "./output",
  cacheDir: "./cache",
  updateInterval: 24,
  autoUpdate: true,
};

// Update WCAG documentation command
program
  .command("update-docs")
  .description("Fetch and update WCAG documentation using the scraper")
  .option("-u, --url <url>", "WCAG base URL", defaultConfig.wcagBaseUrl)
  .option("-o, --output <dir>", "Output directory", defaultConfig.outputDir)
  .option("-c, --cache <dir>", "Cache directory", defaultConfig.cacheDir)
  .action(async (options) => {
    const config = { ...defaultConfig, ...options };
    const bridge = new AccessibilityIntegrationBridge(config);

    try {
      await bridge.initialize();
      await bridge.updateWCAGDocumentation();
      await bridge.cleanup();
    } catch (error) {
      console.error(
        chalk.red("Error:"),
        error instanceof Error ? error.message : "Unknown error"
      );
      process.exit(1);
    }
  });

// Comprehensive analysis command
program
  .command("analyze")
  .description("Perform comprehensive accessibility analysis")
  .option("-h, --html <html>", "HTML content to analyze")
  .option("-u, --url <url>", "URL to fetch and analyze")
  .option("-f, --file <file>", "HTML file to analyze")
  .option("-o, --output <dir>", "Output directory", defaultConfig.outputDir)
  .action(async (options) => {
    const config = { ...defaultConfig, ...options };
    const bridge = new AccessibilityIntegrationBridge(config);

    try {
      await bridge.initialize();

      let html: string;
      if (options.file) {
        html = await fs.readFile(options.file, "utf-8");
      } else if (options.url) {
        const response = await fetch(options.url);
        html = await response.text();
      } else if (options.html) {
        html = options.html;
      } else {
        throw new Error("Must provide HTML content, URL, or file path");
      }

      const report = await bridge.analyzeAccessibility(html, options.url);

      console.log(chalk.green("\n📊 Analysis Summary:"));
      console.log(`  • Total Issues: ${report.summary.totalIssues}`);
      console.log(`  • Compliance Level: ${report.summary.complianceLevel}`);
      console.log(`  • Meets AA: ${report.summary.meetsAA ? "✅" : "❌"}`);
      console.log(`  • ARIA Issues: ${report.summary.ariaIssues}`);

      await bridge.cleanup();
    } catch (error) {
      console.error(
        chalk.red("Error:"),
        error instanceof Error ? error.message : "Unknown error"
      );
      process.exit(1);
    }
  });

// Integration status command
program
  .command("status")
  .description("Check integration status and component health")
  .action(async () => {
    const spinner = ora("Checking integration status...").start();

    try {
      // Check if both components are available
      const scraperAvailable = await fs.pathExists(
        "../accessibility-scraper/src/index.ts"
      );
      const evaluatorAvailable = await fs.pathExists(
        "../mcp-accessibility-evaluator/src/index.ts"
      );

      // Check cache status
      const cacheExists = await fs.pathExists(defaultConfig.cacheDir);
      const cacheData = cacheExists
        ? await fs
            .readJson(path.join(defaultConfig.cacheDir, "wcag-data.json"))
            .catch(() => null)
        : null;

      spinner.succeed("Integration status checked");

      console.log(chalk.blue("\n🔍 Integration Status:"));
      console.log(
        `  • Accessibility Scraper: ${scraperAvailable ? "✅ Available" : "❌ Not Found"}`
      );
      console.log(
        `  • MCP Evaluator: ${evaluatorAvailable ? "✅ Available" : "❌ Not Found"}`
      );
      console.log(
        `  • Cache Directory: ${cacheExists ? "✅ Exists" : "❌ Missing"}`
      );

      if (cacheData) {
        console.log(
          `  • WCAG Data: ✅ ${cacheData.guidelines?.length || 0} guidelines, ${cacheData.successCriteria?.length || 0} criteria`
        );
        console.log(
          `  • Last Updated: ${new Date(cacheData.lastUpdated).toLocaleString()}`
        );
      } else {
        console.log(`  • WCAG Data: ❌ Not cached`);
      }
    } catch (error) {
      spinner.fail("Failed to check integration status");
      console.error(
        chalk.red("Error:"),
        error instanceof Error ? error.message : "Unknown error"
      );
    }
  });

// Help command
program
  .command("help-integration")
  .description("Show detailed integration help")
  .action(() => {
    console.log(
      chalk.blue.bold("\n🌉 Accessibility Integration Bridge Help\n")
    );

    console.log(chalk.yellow("📋 Available Commands:"));
    console.log("  • update-docs    - Fetch latest WCAG documentation");
    console.log(
      "  • analyze        - Perform comprehensive accessibility analysis"
    );
    console.log("  • status         - Check integration status");
    console.log("  • help-integration - Show this help");

    console.log(chalk.yellow("\n🔧 Integration Features:"));
    console.log("  • Live WCAG documentation fetching");
    console.log("  • Automatic rule updates");
    console.log("  • Comprehensive analysis pipeline");
    console.log("  • Unified configuration");
    console.log("  • Cached documentation");

    console.log(chalk.yellow("\n💡 Usage Examples:"));
    console.log("  # Update WCAG documentation");
    console.log("  npm run integration update-docs");
    console.log("");
    console.log("  # Analyze HTML content");
    console.log("  npm run integration analyze --html '<html>...</html>'");
    console.log("");
    console.log("  # Analyze URL");
    console.log("  npm run integration analyze --url https://example.com");
    console.log("");
    console.log("  # Analyze file");
    console.log("  npm run integration analyze --file ./test.html");
    console.log("");
    console.log("  # Check status");
    console.log("  npm run integration status");
  });

// Error handling
process.on("uncaughtException", (error) => {
  console.error(chalk.red("Uncaught Exception:"), error.message);
  process.exit(1);
});

process.on("unhandledRejection", (reason) => {
  console.error(chalk.red("Unhandled Rejection:"), reason);
  process.exit(1);
});

// Parse commands
program.parse();
