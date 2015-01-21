module RTDI
  class IDSocket
    set :livestatus_path, nil
    require 'socket'
    require 'ipaddress'
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
    
    def self.path_is_ip(ls_path)
      is_ip = IPAddress.valid? ls_path
      return is_ip
    end
    def self.connect()
      if path_is_ip(settings.livestatus_path)
        socket = TCPSocket.open(settings.livestatus_path.split(":")[0],settings.livestatus_path.split(":")[1])
      else
        socket = UNIXSocket.open("/var/lib/icinga/rw/live")
      end
      return socket
    end
  end
end
