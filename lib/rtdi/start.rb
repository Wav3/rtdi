module RTDI
  class Getdata
    require 'csv'
    def self.start(csv_file)
      values = []
      i = 0
      CSV.foreach(csv_file) do |row|
        if row[0][0] != "#"
          values[i] = row
          values[i][0] = values[i][0].to_i
          values[i][4] = to_bool(values[i][4])
          values[i][5] = to_bool(values[i][5])
          i += 1
        end
      end
      return obj_data(values)
    end

    def self.sample()
      labels = ["Server 1","Server 2","Server 3","Server 4","Server 5","Server 6","Server 7","Server 8","Server 9","WAN","LAN","WLAN","TK","Mail","Fax","Temp","Power Usage"]
      values = labels.length.times.map{Random.rand(0..6)}
      values[-2] = [Random.rand(14.0..22.0).round(2).to_s + " &deg;C",0]
      values[-1] = [Random.rand(3000..14000).to_s + " W",0]
      tile1 = Status.prepare(labels[0,3],values[0,3])
      tile2 = Status.prepare(labels[3,4],values[3,4])
      tile3 = Status.prepare(labels[7,2],values[7,2])
      tile4 = Status.prepare(labels[9,3],values[9,3])
      tile5 = Status.prepare(labels[12,3],values[12,3])
      tile6 = Status.raw([""],labels[15],values[15])
      tile6 = Status.raw(tile6,labels[16],values[16])
      val = [tile1,tile2,tile3,tile4,tile5,tile6]
      status = []
      i = 0
      val.each do |item|
        status << item[-1]
        val[i].delete(item[-1])
        i += 1
      end
      return val, status
    end

    private

    def self.to_bool(str)
      if str == "false"
        res = false
      elsif str == "true"
        res = true
      end
      return res
    end

    def self.obj_data(objects)
      # Aufbau des Array
      # objects = [ ["Kachelnr","Realer Name","Objektname in Icinga","Typ (Service|Host)","Objekt ist eine Gruppe (Boolean)","Perfomancedaten (Boolean)","Suffix (String)" ], [  ], [  ] ]
      labels = []
      # Aufbau des Array
      # labels = [ [ "a","b","c","d" ], [  ], [  ] ]
      values = []
      # Aufbau des array
      # values = [ [ "werta","wertb","wertc","wertd" ], [  ], [  ] ]
      raw_val = []
      obj_length = objects.length
      prev_nr = 0
      y = 0
      suffix = []
      labels << []
      values << []
      raw_val << []
      while y != obj_length
        if objects[y][0] != prev_nr
          labels << []
          values << []
          raw_val << []
        end
        prev_nr = objects[y][0]
        y += 1
      end
      objects.each do |item|
        position = item[0]
        labels[position] << item[1]
        obj_name = item[2]
        type = item[3]
        group = item[4]
        raw = item[5]
        suffix << item[6]
        if raw == false
          values[position] << Status.getstate(obj_name,type,group)
          raw_val[position] << false
        else
          values[position] << Status.getperfdata(obj_name)
          raw_val[position] << true
        end
      end
      newval = []
      i = 0
      values.each do |item|
        newval << prepare_data(item,labels[i],raw_val[i],suffix)
        i += 1
      end
      status = []
      i = 0
      newval.each do |item|
        status << item[-1]
        newval[i].delete(item[-1])
        i += 1
      end
      return newval, status
    end

    def self.kpoints(value)
      if value.to_f >= 100000.0
        value = value.to_s.insert(3, ".")
      elsif value.to_f >= 10000.0
        value = value.to_s.insert(2, ".")
      elsif value.to_f >= 1000.0
        value = value.to_s.insert(1, ".")
      end
      return value.to_s
    end

    def self.prepare_data(values,labels,raw_val,sfx)
      i = 0
      tval = []
      tlab = []
      tmpval = []
      tmplab = []
      tstat = []
      values.each do |x|
        z = ""
        if raw_val[i] == true
          if x.class.to_s == "Array"
            x.each do |c|
              if c.class.to_s == "String"
                tstat << kpoints(c)
              else
                z = z + c[0] + " "
              end
            end
            x = z
          end
          if sfx[i] != nil
          x = x + sfx[i]
          end
          tval << x
          tlab << labels[i]
        else
          tmpval << x
          tmplab << labels[i]
        end
        i += 1
      end
      if tmpval.length > 0
        values = tmpval
        labels = tmplab
      end
      values = Status.prepare(labels,values)
      i = 0
      if tval.length > 1
        tval.each do |z|
          values = Status.raw(values,tlab[i],[z,tstat[i]])
          i += 1
        end
      elsif tval.length == 1
	    if tval.class.to_s == "Array"
		  tval = tval[0]
		end
        values = Status.raw(values,tlab[i],[tval,tstat[i]])
      end
      return values
    end
  end
end
