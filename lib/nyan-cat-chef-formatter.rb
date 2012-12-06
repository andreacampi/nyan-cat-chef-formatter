require 'chef/formatters/minimal'

class Chef
  module Formatters
    class NyanCat < Formatters::Minimal

      cli_name(:nyan)

      ESC      = "\e["
      NND      = "#{ESC}0m"
      PASS     = '='
      PASS_ARY = ['-', '_']
      FAIL     = '*'
      ERROR    = '!'
      UPDATED  = '+'

      # attr_reader :current, :example_results, :color_index, :pending_count,
      #             :failure_count, :example_count
      # 
      def initialize(out, err)
        super

        @started = @finished = false
      end

      def run_start(version)
        super

        @total_count = 0
        @current = @color_index = @failure_count = @updated_count = 0
        @ticks = []
      end

      # Called before convergence starts
      def converge_start(run_context)
        @total_count = run_context.resource_collection.all_resources.size # + 150
        @started = true
        puts "Converging #{run_context.resource_collection.all_resources.size} resources"
      end

      def converge_complete
        @finished = true
        dump_progress
        super
      end

      def resource_failed_retriable(resource, action, retry_count, exception)
        return unless @started
        @failure_count += 1
        tick FAIL
      end

      def resource_failed(resource, action, exception)
        return unless @started
        @failure_count += 1
        tick FAIL
      end

      def resource_skipped(resource, action, conditional)
        return unless @started
        tick PASS
      end

      def resource_up_to_date(resource, action)
        return unless @started
        tick PASS
      end

      # Called after a resource has been completely converged.
      def resource_updated(resource, action)
        updated_resources << resource
        return unless @started
        @updated_count += 1
        tick UPDATED
      end

      def tick(mark = PASS)
        @ticks << mark
        @current += 1
        @total_count = @current if @current > @total_count
        dump_progress
      end

      # Determine which Ascii Nyan Cat to display. If tests are complete,
      # Nyan Cat goes to sleep. If there are failing or pending examples,
      # Nyan Cat is concerned.
      #
      # @return [String] Nyan Cat
      def nyan_cat
        if self.failed? && self.finished?
          ascii_cat('x')[@color_index%2].join("\n") #'~|_(x.x)'
        elsif self.failed?
          ascii_cat('o')[@color_index%2].join("\n") #'~|_(o.o)'
        elsif self.finished?
          ascii_cat('-')[@color_index%2].join("\n") # '~|_(-.-)'
        else
          ascii_cat('^')[@color_index%2].join("\n") # '~|_(^.^)'
        end
      end

      # Displays the current progress in all Nyan Cat glory
      #
      # @return nothing
      def dump_progress
        padding = @total_count.to_s.length * 2 + 2
        line = nyan_trail.split("\n").each_with_index.inject([]) do |result, (trail, index)|
          value = "#{scoreboard[index]}/#{@total_count}:"
          result << format("%s %s", value, trail)
        end.join("\n")
        output.print line + eol
      end

      # Determines how we end the trail line. If complete, return a newline etc.
      #
      # @return [String]
      def eol
        return "\n" if @finished
        length = (nyan_cat.split("\n").length - 1)
        length > 0 ? format("\e[1A" * length + "\r") : "\r"
      end

      # Calculates the current flight length
      #
      # @return [Fixnum]
      def current_width
        padding    = @total_count.to_s.length * 2 + 6
        cat_length = nyan_cat.split("\n").group_by(&:size).max.first
        padding    + (@current >= @total_count ? @total_count : @current) + cat_length
      end

      # A Unix trick using stty to get the console columns
      #
      # @return [Fixnum]
      def terminal_width
        if defined? JRUBY_VERSION
          default_width = 80
        else
          default_width = `stty size`.split.map { |x| x.to_i }.reverse.first - 1
        end
        @terminal_width ||= default_width
      end

      # Creates a data store of pass, failed, and pending example results
      # We have to pad the results here because sprintf can't properly pad color
      #
      # @return [Array]
      def scoreboard
        padding = @total_count.to_s.length
        [ @current.to_s.rjust(padding),
          green((@current - @updated_count - @failure_count).to_s.rjust(padding)),
          blue(@updated_count.to_s.rjust(padding)),
          red(@failure_count.to_s.rjust(padding)) ]
      end

      # Creates a rainbow trail
      #
      # @return [String] the sprintf format of the Nyan cat
      def nyan_trail
        marks = @ticks.map{ |mark| highlight(mark) }
        marks.shift(current_width - terminal_width) if current_width >= terminal_width
        nyan_cat_lines = nyan_cat.split("\n").each_with_index.map do |line, index|
          format("%s#{line}", marks.join)
        end.join("\n")
      end

      # Ascii version of Nyan cat. Two cats in the array allow Nyan to animate running.
      #
      # @param o [String] Nyan's eye
      # @return [Array] Nyan cats
      def ascii_cat(o = '^')
        [[ "_,------,   ",
            "_|  /\\_/\\ ",
            "~|_( #{o} .#{o})  ",
            " \"\"  \"\" "
          ],
          [ "_,------,   ",
            "_|   /\\_/\\",
            "^|__( #{o} .#{o}) ",
            "  \"\"  \"\"    "
          ]]
      end

      # Colorizes the string with raindow colors of the rainbow
      #
      # @params string [String]
      # @return [String]
      def rainbowify(string)
        c = colors[@color_index % colors.size]
        @color_index += 1
        "#{ESC}38;5;#{c}m#{string}#{NND}"
      end

      # Calculates the colors of the rainbow
      #
      # @return [Array]
      def colors
        @colors ||= (0...(6 * 7)).map do |n|
          pi_3 = Math::PI / 3
          n *= 1.0 / 6
          r  = (3 * Math.sin(n           ) + 3).to_i
          g  = (3 * Math.sin(n + 2 * pi_3) + 3).to_i
          b  = (3 * Math.sin(n + 4 * pi_3) + 3).to_i
          36 * r + 6 * g + b + 16
        end
      end

      # Determines how to color the example.  If pass, it is rainbowified, otherwise
      # we assign red if failed or yellow if an error occurred.
      #
      # @return [String]
      def highlight(mark = PASS)
        case mark
        when PASS; rainbowify PASS_ARY[@color_index%2]
        when FAIL; "\e[31m#{mark}\e[0m"
        when ERROR; "\e[33m#{mark}\e[0m"
        when UPDATED; "\e[34m#{mark}\e[0m"
        else mark
        end
      end

      # Converts a float of seconds into a minutes/seconds string
      #
      # @return [String]
      def format_duration(duration)
        seconds = ((duration % 60) * 100.0).round / 100.0   # 1.8.7 safe .round(2)
        seconds = seconds.to_i if seconds.to_i == seconds   # drop that zero if it's not needed

        message = "#{seconds} second#{seconds == 1 ? "" : "s"}"
        message = "#{(duration / 60).to_i} minute#{(duration / 60).to_i == 1 ? "" : "s"} and " + message if duration >= 60

        message
      end

      def finished?
        @finished
      end

      def failed?
        @failure_count.to_i > 0
      end

      def green(text); "\e[32m#{text}\e[0m"; end
      def red(text); "\e[31m#{text}\e[0m"; end
      def yellow(text); "\e[33m#{text}\e[0m"; end
      def blue(text); "\e[34m#{text}\e[0m"; end
    end
  end
end
