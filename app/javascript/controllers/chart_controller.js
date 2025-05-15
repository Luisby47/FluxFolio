import { Controller } from "@hotwired/stimulus"

/**
 * Chart Controller
 * 
 * This Stimulus controller manages chart rendering and behavior in the application.
 * It supports both doughnut charts (for portfolio allocation) and line charts (for performance tracking).
 * The controller handles initialization, data formatting, and theme-aware styling.
 */
export default class extends Controller {
  // Elements that can be targeted in the DOM
  static targets = ["canvas"]
  
  // Values that can be passed from HTML
  static values = {
    chartType: String, // Type of chart to render ('doughnut' or 'line')
    data: Object,      // Chart data with labels and values
  }

  /**
   * Initialize chart when controller connects to the DOM
   */
  connect() {
    this.initializeChart()
  }

  /**
   * Create and render the chart with appropriate styling based on theme
   */
  initializeChart() {
    // Detect if dark mode is active to adjust styling accordingly
    const isDarkMode = document.documentElement.classList.contains("dark")
    const textColor = isDarkMode ? "#9ca3af" : "#374151"
    const gridColor = isDarkMode ? "#374151" : "#e5e7eb"

    // Chart configuration with theme-aware styling
    const config = {
      type: this.chartTypeValue,
      data: this.chartData,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: "right",
            labels: {
              color: textColor,
              padding: 20,
              font: {
                size: 12,
              },
            },
          },
          tooltip: {
            callbacks: {
              // Format tooltip labels with currency formatting
              label: function (context) {
                const value = context.raw
                const total = context.dataset.data.reduce((a, b) => a + b, 0)
                const percentage = ((value / total) * 100).toFixed(1)
                return `${context.label}: ${new Intl.NumberFormat("en-US", {
                  style: "currency",
                  currency: "USD",
                }).format(value)}`
              },
            },
          },
        },
        // Scale configuration only applies to line charts
        scales:
          this.chartTypeValue === "line"
            ? {
                x: {
                  grid: {
                    color: gridColor,
                  },
                  ticks: {
                    color: textColor,
                  },
                },
                y: {
                  grid: {
                    color: gridColor,
                  },
                  ticks: {
                    color: textColor,
                    // Format y-axis values as currency
                    callback: function (value) {
                      return new Intl.NumberFormat("en-US", {
                        style: "currency",
                        currency: "USD",
                      }).format(value)
                    },
                  },
                },
              }
            : undefined,
      },
    }

    // Initialize Chart.js with the canvas element and configuration
    new Chart(this.canvasTarget, config)
  }

  /**
   * Format chart data based on chart type
   * @returns {Object} Formatted chart data for Chart.js
   */
  get chartData() {
    const data = this.dataValue

    // Doughnut chart configuration (used for allocation charts)
    if (this.chartTypeValue === "doughnut") {
      const chartData = {
        labels: data.labels,
        datasets: [
          {
            data: data.values,
            backgroundColor: this.generateColors(data.labels.length),
            borderWidth: 1,
            borderColor: document.documentElement.classList.contains("dark") ? "#1f2937" : "#ffffff",
          },
        ],
      }
      return chartData
    }

    // Line chart configuration (used for performance charts)
    if (this.chartTypeValue === "line") {
      const isDarkMode = document.documentElement.classList.contains("dark")
      return {
        labels: data.labels,
        datasets: [
          {
            label: "Portfolio Value",
            data: data.values,
            borderColor: "#3b82f6",
            backgroundColor: isDarkMode ? "rgba(59, 130, 246, 0.2)" : "rgba(59, 130, 246, 0.1)",
            fill: true,
            tension: 0.4,
          },
        ],
      }
    }
  }

  /**
   * Generate visually distinct colors for chart segments
   * @param {number} count - Number of colors needed
   * @returns {Array} Array of color values
   */
  generateColors(count) {
    const colors = []
    const baseHues = [210, 330, 120, 45, 275, 175, 15, 300] // Predefined hues for better color distribution

    for (let i = 0; i < count; i++) {
      const hue = baseHues[i % baseHues.length]
      const isDarkMode = document.documentElement.classList.contains("dark")

      if (isDarkMode) {
        colors.push(`hsla(${hue}, 70%, 60%, 0.8)`) // Brighter, slightly transparent colors for dark mode
      } else {
        colors.push(`hsl(${hue}, 70%, 50%)`) // Standard colors for light mode
      }
    }

    return colors
  }
}
