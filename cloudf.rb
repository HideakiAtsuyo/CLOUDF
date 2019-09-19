#!/usr/bin/env ruby
# encoding: UTF-8
require 'net/http'
require 'open-uri'
require 'json'
require 'socket'
require 'optparse'
require 'is_down'

class String
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end

def underline;      "\e[4m#{self}\e[24m" end
def bold;           "\e[1m#{self}\e[21m" end
def italic;         "\e[3m#{self}\e[23m" end
end
def banner()

system("clear")
puts "\n"
puts "====================================================".blue
puts "\n"
puts" ██████╗██╗      ██████╗ ██╗   ██╗██████╗   ███████╗".blue
puts"██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗  ██╔════╝".blue
puts"██║     ██║     ██║   ██║██║   ██║██║  ██║  █████╗".blue
puts"██║     ██║     ██║   ██║██║   ██║██║  ██║  ██╔══╝".blue
puts"╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝  ██║".blue
puts" ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝   ╚═╝".blue
puts "====================================================".blue


puts "Identifie l'IP réelle d'un site Web protégé par CloudFlare.".green
puts "github.com/LeMalCestBien".green

puts "\n"
end

options = {:bypass => nil, :massbypass => nil}
parser = OptionParser.new do|opts|

    opts.banner = "Exemple: ruby cloudf.rb -b <cible> ou ruby cloudf.rb --byp <cible>"
    opts.on('-b ','--byp ', 'Découvre la vraie IP (bypass CloudFlare)', String)do |bypass|
    options[:bypass]=bypass;
    end

    opts.on('-h', '--help', 'Help') do
        banner()
        puts opts
        puts "Exemple: ruby cloudf.rb -b discordapp.com ou ruby cloudf.rb --byp discordapp.com"
        exit
    end
end

parser.parse!


banner()

if options[:bypass].nil?
    puts "URL -b or --byp"
else
	begin
	option = options[:bypass]
	payload = URI ("http://www.crimeflare.org:82/cgi-bin/cfsearch.cgi")
	request = Net::HTTP.post_form(payload, 'cfS' => options[:bypass])

	response =  request.body
	nscheck = /Aucun nameserver fonctionnel n'a été enregistré/.match(response)
	if( !nscheck.nil? )
		puts "[-] Aucune adresse valide - Êtes-vous sûr que c'est un domaine protégé par CloudFlare ?\n"
		exit
	end
	regex = /(\d*\.\d*\.\d*\.\d*)/.match(response)
	if( regex.nil? || regex == "" )
		puts "[-] Aucune adresse valide - Êtes-vous sûr que c'est un domaine protégé par CloudFlare ?\n"
		exit
	end
rescue
	puts "Erreur Fatale !"
end
	ip_real = IPSocket.getaddress (options[:bypass])

	puts "[+] Site analysé: ".red + "#{option}".blue.underline.bold.italic
	puts "[+] IP CloudFlar: ".red + "#{ip_real}".blue.underline.bold.italic
	puts "[+] Vraie IP: ".red + "#{regex}".blue.underline.bold.italic
	target = "http://ipinfo.io/#{regex}/json"
	url = URI(target).read
	json = JSON.parse(url)
	puts "[+] Nom d'hôte: ".red + json['hostname'].to_s.blue.underline.bold.italic
	puts "[+] Pays: ".red + json['country'].blue.underline.bold.italic
	puts "[+] Région: ".red + json['region'].blue.underline.bold.italic
	puts "[+] Ville: ".red  + json['city'].blue.underline.bold.italic
	puts "[+] Localisation: ".red + json['loc'].blue.underline.bold.italic
	puts "[+] Organisation:".red + json['org'].blue.underline.bold.italic
	down = IsDown.is_down?("#{option}")
	if IsDown.is_down?(option)
		puts "[+] Status: ".red + "Hors-ligne".blue.underline.bold.italic
	else
		puts "[+] Status: ".red + "En ligne".blue.underline.bold.italic
	end
end
