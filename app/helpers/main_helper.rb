module MainHelper
  def treeify(namespaces)
    tree = {}
    namespaces.map{|ns| ns.split(".") }.each do |ns|
      parent = tree
      ns.each do |part|
        parent[part] ||= {}
        parent = parent[part]
      end
    end
    tree
  end

  def generate_level(lib, version, current_ns, root, path = [])
    ret = "<ul>"
    root.each do |k, v|
      ns = path.empty? ? k : path.join(".") + "." + k
      ret << <<-EOF
        <li><span class="#{current_ns == ns ? "current_ns" : ""}">
        #{link_to k,
                    :controller => 'main',
                    :action => 'ns',
                    :lib => lib,
                    :version => version,
                    :ns => ns}
        </span>
      EOF
      ret << generate_level(lib, version, current_ns, v, path + [k]) if v.size > 0
    end
    ret << "</ul>"
    ret
  end
end
