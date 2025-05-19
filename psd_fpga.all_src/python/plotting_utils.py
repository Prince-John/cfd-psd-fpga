"""
init plotter
"""
import matplotlib
import numpy as np
from matplotlib import pyplot as plt
import mpld3
import json

matplotlib.use('TkAgg')


class HistogramPlotter:
    def __init__(self, bin_size, adc_min=0, adc_max=1023, max_events=1000):
        """
        Initialize the histogram plotter.

        Parameters:
          bin_size (int): Size of each histogram bin.
          adc_min (int): Minimum possible ADC value.
          adc_max (int): Maximum possible ADC value.
        """
        self.max_events = max_events
        self.bin_size = bin_size
        self.adc_min = adc_min
        self.adc_max = adc_max
        # Create bins based on the provided bin size
        self.bins = np.arange(adc_min, adc_max + bin_size, bin_size)
        # Initialize storage for ADC data for integrators 0, 1, and 2.
        self.adc_data = {0: [], 1: [], 2: []}
        self.events = 0
        # Create three subplots (one for each integrator: 0, 1, 2)
        self.fig, self.axs = plt.subplots(3, 1, figsize=(10, 8))
        #plt.ion()  # enable interactive mode for live updates
        plt.show()

    def update_plots(self):
        """Update histograms for integrators 0, 1, and 2."""

        for integrator in [0, 1, 2]:
            ax = self.axs[integrator]
            ax.clear()
            # Plot the histogram with the configured bins
            ax.hist(self.adc_data[integrator], bins=self.bins, edgecolor='black')
            ax.set_title(f"Integrator {integrator} ADC Histogram")
            ax.set_xlabel("ADC Value")
            ax.set_ylabel("Count")
        self.fig.tight_layout()
        self.fig.canvas.draw()
        self.fig.canvas.flush_events()

    def process_event_packet(self, event_packet):
        """
        Process a single event packet.

        This method extracts ADC values for integrators "0", "1", and "2"
        and appends them to the respective histogram data lists.
        """
        self.events += 1
        integrators_data = event_packet.get("integrators", {})
        # Only process integrators "0", "1", and "2"
        for integrator_key in [0, 1, 2]:
            adc_value = integrators_data.get(integrator_key)
            if adc_value is not None:
                # Convert key to int for consistency in our adc_data dictionary.
                self.adc_data[integrator_key].append(adc_value)

        if self.events % 10 == 0:
            print(f'{self.events} events processed!')
        if self.events >= self.max_events:
            raise KeyboardInterrupt

    def save_interactive(self, filename="interactive_plot.html"):
        """
        Save the current figure as an interactive HTML file.
        You can open this file in a web browser and zoom/pan the plot.
        """
        path = f"./adc_histograms/{filename}.html"
        mpld3.save_html(self.fig, path)
        print(f"Interactive figure saved as {path}")

    def save_hist_data(self, filename):
        path = f"./adc_histograms/raw-data-for-{filename}.json"

        data = {
            "adc_data": self.adc_data,
            "bins": self.bins.tolist(),
            "total events": self.events
        }

        with open(path, 'w') as fp:
            json.dump(data, fp, indent=4)
        print(f"Interactive figure data saved as {path}")

    def cleanup(self):
        print(f"Processed {self.events} events!")
        plt.ioff()
        plt.close(self.fig)
