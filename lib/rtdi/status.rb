module RTDI
  class Status
    private

#
# === Args:
# +list+::
#  Array with stati
#
# === Description:
# Puts a totalstatus of a array
#
# === Return:
# +status+::
#  Returns a totalstatus of a array
#

    def self.stateall(list)
      i = 0
      list.each do |item|
        if item.class.to_s != "Array"
          list[i] = list[i].to_i
        else
          list[i] = list[i][1].to_i
        end
        i += 1
      end
      sorted = bubble(list)
      i = 0
      sorted = case sorted[-1]
        when 0 then "normal"
        when 1 then "unknownack"
        when 2 then "warningack"
        when 3 then "criticalack"
        when 4 then "unknown"
        when 5 then "warning"
        when 6 then "danger"
      end
      return sorted
    end
#
# === Args:
# +list+::
#  array which should be sorted
#
# === Description:
# Sorts a array (DESC)
#
# === Return:
# +list+::
#  Sorted array
#

    def self.bubble(list)
      return list if list.class.to_s != "Array"
      return list if list.size <= 1 # already sorted
      swapped = true
  	while swapped do
  	  swapped = false
  	  0.upto(list.size-2) do |i|
  	    if list[i] > list[i+1]
  	      list[i], list[i+1] = list[i+1], list[i] # swap values
    	      swapped = true
  	    end
        end
      end
    list
    end

#
# === Args:
# +hostgroup+::
# Objectname of the hostgroup in icinga
#
# === Description:
# Gets all groupmember
#
# === Return:
# +erg+::
# Returns all groupmember [array]
#

    def self.hgm(hostgroup)
      erg = RTDI::IDSocket.request("hostgroups","members","name = #{hostgroup}").split(",")
      return erg
    end

#
# === Args:
# +servicegroup+::
# Objectname of the servicegroup in icinga
#
# === Description:
# Gets all groupmember
#
# === Return:
# +erg+::
# Returns all groupmember [array]
#
    def self.sgm(servicegroup)
      erg = RTDI::IDSocket.request("servicegroups","members","name = #{servicegroup}").split(",")
      i = 0
      return erg
    end

#
# === Args:
# +name+::
# Name in icinga
# +qa+::
# type of the object (Hostgroup, Service, Host)
#
# === Description:
# Gets the data from the icinga host
#
# === Return:
# +erg+::
# Returns a status and the "acknowledgment"
#

    def self.get(name,qa)
      begin
        erg = case qa
          when "ssh" then RTDI::IDSocket.request("services","state acknowledged","host_name = #{name}")
          when "hsh" then RTDI::IDSocket.request("hosts","state acknowledged","host_name = #{name}")
          when "hs" then RTDI::IDSocket.request("hosts","state acknowledged","name = #{name}")
          when "ssd" then RTDI::IDSocket.request("services","state acknowledged","display_name = #{name}")
           when "sgi" then RTDI::IDSocket.request("services","state acknowledged","host_name = #{name[0]}","display_name = #{name[1]}")
        end
        if erg.length == 0
          raise 'Das Objekt "' + name.to_s + '" existiert nicht in Icinga!'
        end
      if qa == "ssh" then
        tmp = []
        erg_length = erg.length / 3
        i = 0
        erg_length.downto(0) do |item|
          tmp[item] = erg[i,3]
          i += 3
        end
        erg = tmp[1,erg.length]
        i = 0
        erg.each do |item|
          erg[i] = casestate(item,qa[0])
          i += 1
        end
        erg = bubble(erg)[-1]
      else
        erg = casestate(erg,qa[0])
      end
      rescue Exception => e
        puts "Es ist ein Fehler aufgetreten: " + e.message
        puts "Objekttyp: unknown"
      end
    end

#
# === Args:
# +value+::
# A value which should convert
# +type+::
# (s)ervice | (h)ost
#
# === Description:
# convert a status + "acknowledged" in a dashing-readable format
#
# === Return:
# +erg+::
# Returns the status
#

    def self.casestate(value,type)
      if type == "s"
        erg = case value
          when "0;0","0" then 0
          when "3;1" then 1
          when "1;1" then 2
          when "2;1" then 3
          when "3;0","3" then 4
          when "1;0","1" then 5
          when "2;0","2" then 6
        end
      elsif type == "h"
        erg = case value
          when "0;0","0" then 0
          when "1;1" then 3
          when "1;0","1" then 6
        end
      end
      return erg
    end


#
# === Args:
# +state+::
# status, which schould be converted to numeric [string]
#
# === Description:
# Converts a named status to a numeric status
#
# === Return:
# +conv+::
# Returns the nummeric status

    def self.convback(state)
      conv = case state
        when "normal" then 0
        when "unknownack" then 1
        when "warningack" then 2
        when "criticalack" then 3
        when "unknown" then 4
        when "warning" then 5
        when "critical","danger" then 6
      end
      return conv
    end

#
# === Args:
# +groupname+::
# Name of the groupobject
#
# === Description:
# Gets the status of all hosts in a hostgroup
#
# === Return:
# +res+::
# Returns a status of all hosts

    def self.getgroup(groupname)
      begin
        res = hgm(groupname)
        if res.length == 0
          raise 'Das Objekt "' + groupname + '" existiert nicht in Icinga!'
        end
        i = 0
        res.each do |item|
          res[i] = get(item, "hsh")
          i += 1
        end
        res = bubble(res)[-1]
      rescue Exception => e
        puts "Es ist ein Fehler aufgetreten: " + e.message
        puts "Objekttyp: Servicegroup"
      end
      return res
    end

#
# === Args:
# +groupname+::
# Name of the groupobject
#
# === Description:
# Gets the status of all hosts in a hostgroup and its services
#
# === Return:
# +res+::
# Returns a stati of all hosts and services

    def self.gs(groupname,servicename)
      begin
        member = sgm(groupname)
        if member.length == 0
          raise 'Das Objekt "' + groupname.to_s + '" existiert nicht in Icinga!'
        end
        i = 0
        res = []
        member.each do |item|
          res[i] = RTDI::IDSocket.request("services","perf_data state","host_name = #{item.split("|")[0]}","display_name = #{servicename}")
          if res[i] == 0
            raise 'Das Objekt "' + item.split("|")[0] + '" und dem Service "' + servicename.to_s + '" existiert nicht!'
          end
          i += 1
        end
        x = 0
        state = []
        res.each do |item|
          state[x] = item.split(";")[1]
          res[x] = item.split(";")[0]
          x += 1
        end
        state = bubble(state)[-1]
        res << state
      rescue Exception => e
        puts "Es ist ein Fehler aufgetreten: " + e.message
        puts "Objekttyp: Servicegroup"
      end
      return res
    end


    def self.groupservices(groupname)
      begin
        member = hgm(groupname)
        if member.length == 0
          raise 'Das Objekt "' + groupname.to_s + '" existiert nicht in Icinga!'
        end
        i = 0
        res = []
        member.each do |item|
          res[i] = get(item, "ssh")
          i += 1
        end
        res = bubble(res)[-1]
      rescue Exception => e
        puts "Es ist ein Fehler aufgetreten: " + e.message
        puts "Objekttyp: Hostgroup with services"
      end
      return res
    end

    public
#
#
# === Args:
# +labels+::
#  the Labels [array]
# +values+::
#  host- or service-states [array]
#
# === Description:
# Prepare the host- and service-states
#
# === Return:
# Returns a multidimensional array. Ready to push this to the dashboard [array]
#
    def self.prepare(labels, values)
      status = []
      i = 0
      values.each do |item|
        item = case item
          when 0 then "<i class='icon-ok'></i>"
    	    when 1,2,3 then "<i class='icon-cog'></i>"
  	      when 5 then "<i class='icon-warning-sign'></i>"
	        when 4 then "<i class='icon-question-sign'></i>"
	        when 6 then "<i class='icon-remove'></i>"
        end
        status[i] = {label: labels[i], value: item}
        i +=1
      end
      totalstate = stateall(values)
      status.push(totalstate)
      return status
    end

#
#
# === Args:
# +list+::
#  The old tile [array]
# +label+::
#  Label of the new value [string]
# +value+::
#  The value with the state [array]
# +position+::
#  Position at the tile [integer]
#
# === Description:
# Adds an object to a tile, which should not display by a icon
#
# === Return:
# Returns the new tile (already prepared) [array]
#

    def self.raw(oldlist,lab,value)
      if oldlist.length > 1
        state_old = oldlist.delete(oldlist[-1])
        new_list = oldlist
        newstate = casestate(value[1],"s")
        state_old_cb = convback(state_old)
        gesstate = [state_old_cb.to_i, newstate.to_i]
        gesstate = stateall(gesstate)
        new_list.insert(-1, {label: lab, value: value[0]})
        new_list << gesstate
      elsif oldlist.length == 1
        newstate = casestate(value[1],"s")
        new_list = []
        new_list.insert(-1, {label: lab, value: value[0]})
        new_list << newstate
      end
      return new_list
    end

#
#
# === Args:
# +name+::
#  The name of the object [string]
# +type+::
#  type of the object (service or host) [string]
# +group+::
#  true, if the object is a host- or servicegroup [boolean]
# +etc+::
#  additional object which schould be added to the group [array]
#
# === Description:
# Gets the host- and servicestate
#
# === Return:
# Returns the state of a host, service or a group
#
    def self.getstate(name, type, group=false, etc=nil)
      if group && type == "service"
        res = groupservices(name)
      elsif group
        res = getgroup(name)
      elsif type == "service"
        res = get(name, "ssd")
      elsif type == "servicehost"
        res = get(name, "ssh")
      elsif type == "host"
        res = get(name, "hs")
      end
      return res
    end

#
#
# === Args:
# +name+::
#  The name of the service-object [string]
#
# === Description:
# Gets the perf_data of a service
#
# === Return:
# Return the perf_data
#
    def self.getperfdata(name)
      extname = []
      begin
        if name.index(":")
          extname = name.split(":")
          res = RTDI::IDSocket.request("services","state perf_data","display_name = #{extname[1]}","host_name = #{extname[0]}")
          if res.length == 0
            raise 'Das Objekt "' + extname[0] + '" mit dem Service "' + extname[1] + '" existiert nicht in Icinga!'
          end
        else
          extname[1] = name
          res = RTDI::IDSocket.request("services","state perf_data","display_name = #{extname[1]}")
          if res.length == 0
            raise 'Das Objekt "' + extname[1] + '" existiert nicht in Icinga!'
          end
        end
        res = res.split(";")
        state = res[0]
        res = res[1].scan(/[=]([0-9]+[.,]?[0-9]+)/)
        #res[0] = res[1].split(/[=]([0-9]+[.,]?[0-9]+)/)
        res << state
      rescue Exception => e
        puts "Es ist ein Fehler aufgetreten: " + e.message
        puts "Objekttyp: Service (perf_data)"
      end
      return res
    end
    def self.calcpue()
      energymeter = RTDI::IDSocket.request("services","perf_data","display_name = energymeter_power")
      pdu = RTDI::Status.gs("pdu_activepower","pdu_activepower")
      pue = []
      i = 0
      pdu_strom = 0
      pdu.each do |item|
        if item.length != 1
          pdu_strom += item.gsub!("ActivePower=","").to_i
          i += 1
        end
      end
      energymeter = energymeter.scan(/[=]([0-9]+[.,]?[0-9]+)/)[0][0]
      pue[0] = (pdu_strom.to_f / energymeter.to_f).round 2
      pue[1] = "0"
      return pue
    end
  end
end
