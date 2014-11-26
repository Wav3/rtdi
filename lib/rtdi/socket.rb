module RTDI
  class IDSocket

    require 'socket'

    def self.request(type,columns=nil,filter=nil,extfilter=nil)
      query = "GET #{type.to_s}\n"
      if columns != nil
        query << "Columns: #{columns}\n"
      end
      if filter != nil
        query << "Filter: #{filter}\n"
      end
      if extfilter != nil
        query << "Filter: #{extfilter}\n"
      end
      query << "OutputFormat: csv\n"
      i = 1
      socket = connect()
      socket.puts query
      socket.shutdown(Socket::SHUT_WR)
      res = socket.recv(10000)
      if res[-1] == "\n" && res[-2] == "\n"
        res = res.gsub!("\n\n","")
      elsif res[-1] == "\n" && res[-2] != "\n"
        res = res.gsub!("\n","")
      end
      socket.close
      return res
    end

    private

    def self.connect()
      socket = UNIXSocket.open("/var/lib/icinga/rw/live")
      return socket
    end
  end
end
