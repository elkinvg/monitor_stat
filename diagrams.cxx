#include <fstream>
#include <iostream>
#include <string>
#include <string.h>
#include <sstream>
#include <vector>
#include <stdlib.h>

#include <sys/stat.h>

#ifdef HOME
#include "root/TCanvas.h"
#include "root/TFile.h"
#include "root/TGraph.h"
#include "root/TEllipse.h"
#include "root/TPaveText.h"
#include "root/TPavesText.h"
#include "root/TPad.h"
#include "root/TStyle.h"
#include "root/TPaveLabel.h"
#include "root/TAxis.h"
#else
#include "TCanvas.h"
#include "TFile.h"
#include "TGraph.h"
#include "TPad.h"
#include "TPaveLabel.h"
#include "TAxis.h"
#include "TPaveText.h"

#endif

using namespace std;

vector<int> readDataFromFile(std::string namefile);
void getParametersFromString(string S, vector<int>& Vec);
void makePlotForStation(const vector<int>& StatusTimeNeventsNsec, string statioNumber);
bool checkDir(string nameOfDir);

int main (int argc, char** argv)
{
    if (argc<2) {cerr << "No arguments " << endl; return 1;}

    int stationNumber;

    for (int i=0;i<argc-1;i++)
    {
        string S = argv[i+1];
        if (S.find("LNP")==string::npos) continue;

        size_t beg = 3;
        string stationNumberString = S.substr(beg,(S.find_first_of("_")-beg));

        stationNumber = atoi(stationNumberString.c_str());
        vector<int> vecSTNN;
        vecSTNN = readDataFromFile(argv[i+1]);

        makePlotForStation(vecSTNN, stationNumberString);
    }
}

vector<int> readDataFromFile(std::string namefile)
{
    fstream ifDataFile;
    ifDataFile.open(namefile.c_str(),ios::in);

    std::string S;
    vector<int> StatusTimeNeventsNsec;

    while (!ifDataFile.eof())
    {
       getline(ifDataFile, S);
       getParametersFromString(S,StatusTimeNeventsNsec);
    }

    ifDataFile.close();
    return StatusTimeNeventsNsec;
}

void getParametersFromString(string S, vector<int>& Vec)
{
    string word;
    stringstream SS;
    SS.str(S);

    int i=0;

    while (SS>>word)
    {
        if (i==0)
        {
            if (S.find("LNP")!=string::npos) Vec.push_back(1);
            else Vec.push_back(1);
        }
        else
        {
            if (i==4 || i==5 || i==6) Vec.push_back(atoi(word.c_str()));
        }
        i++;
    }
}

void makePlotForStation(const vector<int>& StatusTimeNeventsNsec, string statioNumber)
{

    string dirname = "./img";
    if (!checkDir(dirname.c_str())) mkdir(dirname.c_str(),0755);
    string nameCanv;
    nameCanv = "Station_"+statioNumber;
    int N = StatusTimeNeventsNsec.size()/4;
    TCanvas *canvas = new TCanvas(nameCanv.c_str(),nameCanv.c_str(),600,300);

    int iVec=0;
    Double_t time[N],nEvent[N],nSec[N],freq[N];

    for (int i=0;i<N;i++)
    {
        iVec++;
        time[i] = StatusTimeNeventsNsec[iVec];
        iVec++;
        nEvent[i] = StatusTimeNeventsNsec[iVec];
        iVec++;
        nSec[i] = StatusTimeNeventsNsec[iVec];
        iVec++;

        if (nSec[i]==0 || nEvent[i]<0) freq[i]=0;
        else freq[i] = nEvent[i] / nSec[i];
    }

    TGraph *graph = new TGraph(N,time,freq);
    canvas->Update();


    graph->SetFillColor(40);
    graph->SetTitle(nameCanv.c_str());

    graph->GetYaxis()->SetTitle("frequency, Hz");
    graph->GetYaxis()->SetTitleSize(0.05);
    graph->GetXaxis()->SetTimeFormat("%d %b %H:%M%F1970-01-01 00:00:00 GMT");
    graph->GetXaxis()->SetTimeDisplay(1);
    graph->GetXaxis()->SetTitle("Time (UTC)");

    graph->GetXaxis()->SetRangeUser(time[0],time[iVec/4]);

    graph->SetMinimum(0);
    graph->Draw("AB");

    TText *labels = new TText(.25,.94,"ON");
    labels->SetNDC();
    labels->SetTextColor(10);
    labels->Draw("same");


    canvas->Update();


    //canvas->SaveAs((dirname+"/"+nameCanv+".png").c_str());
    canvas->Print((dirname+"/"+nameCanv+".png").c_str());

}

bool checkDir(string nameOfDir)
{
    /*
     * Прoверка существования директории nameOfDir
     */

    struct stat buff;
    int tmpcheck = stat(nameOfDir.c_str(),&buff);

    if ( !((tmpcheck == 0) && (S_ISDIR(buff.st_mode))) )
    {
        cerr << " directory " << nameOfDir << " doesn'double exist\n" << endl;
        return false;
    }

    return true;
}
