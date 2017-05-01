// SIL - adaptations for iOS in 22/04/2013

//#include <QMutex> // SIL

#include <stdio.h>
#include <string>
using namespace std;

#include "ofMain.h"   // SIL
#include "ofxiPhone.h" // SIL
#include "ofxiPhoneExtras.h" // SIL

#include "tmpFile.h"

#define TMPFILE_NAME_BASE "tmpfile"
#define LOG_LEVEL LOG_WARN
#define MAX_BLOCK_SIZE 1000
#include "logging.h"

TmpFile::TmpFile(string tmpfile_prefix) {
	int nf=0;
	ficheiro = NULL;
	structDefault = NULL;
	blockSize = 4;
	blocoZero = new float[MAX_BLOCK_SIZE];
	for(int i=0; i<MAX_BLOCK_SIZE; i++) blocoZero[i] = 0.0f;
	mutex = new ofMutex(); // SIL
	fileTmp = new string;
	apagaTmps();
	do {
		//*fileTmp = tmpfile_prefix;// SIL
		//*fileTmp += nf + ".tmp"; // SIL
        *fileTmp = (string)ofxiPhoneGetDocumentsDirectory().c_str(); // SIL
        *fileTmp += tmpfile_prefix + ofToString(nf).c_str() + ".tmp"; // SIL

		LOG(LOG_DEBUG,"Tentar abrir: %s...",fileTmp->c_str())
		nf++;
        ficheiro = fopen(fileTmp->c_str(),"w+b"); // SIL
    } while (nf < 100 && ficheiro == NULL);
	if(nf>99) {
		fileTmp->clear();
		size = -1;
		ficheiro = NULL;
		LOG(LOG_ERROR,"Não foi possivel criar ficheiro temporário")
		return;
	} else size = 0;
	LOG(LOG_DEBUG,"Ficheiro tmp: %s",fileTmp->c_str())
}

TmpFile::~TmpFile() {
	LOG(LOG_DEBUG,"A destruir TMPFILE");
	
    mutex->lock(); // SIL
    size = 0;
    if(structDefault != NULL) delete structDefault;
    delete blocoZero;
    delete mutex;
    fclose(ficheiro);
    delete fileTmp;
    apagaTmps();
    LOG(LOG_DEBUG,"A destruir TMPFILE - FIM");
}

void TmpFile::apagaTmps() {
	remove(fileTmp->c_str());
}

float TmpFile::readFast(int posicao) { // função menos segura
	float saida;
	if(ficheiro == NULL || posicao < 0  || posicao > size) { return 0.0f; }
	
//	QMutexLocker locker(mutex);// SIL
	mutex->lock();// SIL
    if((int)fseek(ficheiro, posicao * sizeof(float), SEEK_SET) != 0){
        mutex->unlock();// SIL
        return 0;
        }
    fread(&saida, sizeof(float), 1, ficheiro);
    mutex->unlock();// SIL
    return saida;
}

int TmpFile::getSize() { return size; }

int TmpFile::readBlock(float *dados, int posicao, int tamanho) {
	int saida, limSup, tmp;
	if(ficheiro == NULL || tamanho < 1 ) return 0;
    
	//QMutexLocker locker(mutex);// SIL
	
    mutex->lock();// SIL
    if(posicao >= size) {
        LOG(LOG_INFO,"Falha da posicao maxima por %i amostras",posicao - size + 1)
        for(limSup = tamanho-1; limSup >= 0; --limSup) dados[limSup] = 0.0f;
        mutex->unlock();
        return 0;
        }
    //LOG(LOG_DEBUG,"Ler de %i a %i", posicao, posicao+tamanho)
    if(posicao < 0) {
        LOG(LOG_INFO,"Falha da posicao minima por %i amostras",-posicao)
        if((int)fseek(ficheiro, 0, SEEK_SET) != 0) { mutex->unlock(); return 0; }
        limSup = posicao + tamanho;
        if(limSup >0) limSup=0;
        // LOG(LOG_ERROR,"ZerarI de 0 a %i",-posicao -1)
        for(saida = posicao; saida < limSup; saida++) dados[saida - posicao] = 0.0f;
        limSup = posicao + tamanho;
        if(limSup <= 0) {mutex->unlock(); return tamanho;}
        saida = (int)fread(dados - posicao, sizeof(float), limSup > size ? size : limSup, ficheiro) - posicao;
        if(saida < tamanho) {
            // LOG(LOG_ERROR,"ZerarF de %i a %i",saida,tamanho-1)
            for(limSup = tamanho-1; limSup >= saida; --limSup) dados[limSup] = 0.0f;
            }
        } else {
            if((int)fseek(ficheiro, posicao * sizeof(float), SEEK_SET) != 0) {mutex->unlock();return 0; }
            saida = (int)fread(dados, sizeof(float), tamanho+posicao>size ? size-posicao : tamanho, ficheiro);
            tmp = saida < 0 ? 0 : saida;
            if(saida < tamanho) {
                // LOG(LOG_ERROR,"ZerarF2 de %i a %i",saida,tamanho-1)
                for(limSup = tamanho-1; limSup >= tmp; --limSup) dados[limSup] = 0.0f;
            }
        }
    mutex->unlock();// SIL
    return saida;
}


bool TmpFile::writeBlockAtEnd(float *dados, int tamanho) {
	if(dados == NULL ||
		size < 0 ||
		tamanho < 1) return false;
    
//	QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
        if((int)fseek(ficheiro, (size > 0 ? size: 0) * sizeof(float), SEEK_SET) != 0) { mutex->unlock();return false;}
        if((int)fwrite(dados, sizeof(float), tamanho, ficheiro) != tamanho) { mutex->unlock();return false;}
        size += tamanho;
    mutex->unlock();// SIL
	return true;
}

bool TmpFile::writeBlock(float *dados, int posicao, int tamanho) {
	if(dados == NULL || size < 0 || posicao < 0  || tamanho < 1 ) return false;
	
    //QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
    if(posicao > size) {
        if(!setSizeZeroInternal(posicao)){
            LOG(LOG_ERROR,"falhou escrita: setSizeZero");
            mutex->unlock();
            return false;
        }
    }
    else {
        if((int)fseek(ficheiro, posicao * sizeof(float), SEEK_SET) != 0){
            LOG(LOG_ERROR,"falhou escrita: movimento do cursor do ficheiro")
            mutex->unlock();
            return false;
        }
    }
    
    int tamanho_teste;
	
    if((tamanho_teste=(int)fwrite(dados, sizeof(float), tamanho, ficheiro)) != tamanho)
        if((tamanho_teste=(int)fwrite(dados, sizeof(float), tamanho, ficheiro)) != tamanho){
            LOG(LOG_ERROR,"falhou escrita: tamanho a escrever = %d !=  escrito = %d",tamanho,tamanho_teste)
            mutex->unlock();
            return false;
            }
    
    if(posicao+tamanho>size) size=posicao+tamanho;
    
    mutex->unlock();// SIL
    return true;
    }

bool TmpFile::trySize(int tamanho) { // cria o que falta com zeros
	if(ficheiro == NULL || size < 0 || tamanho < 0) return false;
	
    //QMutexLocker locker(mutex);// SIL
	
    mutex->lock();// SIL
    if((int)fseek(ficheiro, tamanho , SEEK_SET) == 0) { size = tamanho; mutex->unlock(); return true; }
    printf("Try and failed to a size of %i\n",tamanho);
    mutex->unlock();// SIL 
	return false;
}

bool TmpFile::setSizeZero(int tamanho) { // cria o que falta com zeros
	//QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
    bool baux = setSizeZeroInternal(tamanho);// SIL
    mutex->unlock();// SIL 
    return baux;
}

inline bool TmpFile::setSizeZeroInternal(int tamanho) { // cria o que falta com zeros
	int passo, tam;
	if(ficheiro == NULL || size < 0 || tamanho < 0) return false;
	if(size == 0 && tamanho == 0) return true;
	if(tamanho < size)  { 
		if((int)fseek(ficheiro, tamanho , SEEK_SET) == 0) {
			size = tamanho;
			return true;
		}
		return false;
	}
	passo = tamanho - size;
	// ir para o fim
	if((int)fseek(ficheiro, (size > 0 ? size-1: 0) * sizeof(float), SEEK_SET) != 0) return false;
	while(passo>0) {
		tam = passo > MAX_BLOCK_SIZE? MAX_BLOCK_SIZE: passo;
		if((int)fwrite(blocoZero, sizeof(float), tam, ficheiro) != tamanho) return false;
		passo -= tam;
		size = tamanho - passo; // vai actualizando o tamanho
	}

	return true;
}

bool TmpFile::setStructBlockSize(int bsize, void *structDefault_) {
	if(structDefault_ == NULL || bsize<1) return false;
	
    //QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
    if(structDefault != NULL) delete structDefault;
    blockSize = bsize;
    structDefault = new char[bsize];
    memcpy(structDefault,structDefault_,bsize);
	mutex->unlock();// SIL 
    return true;
}

int TmpFile::readStruct(void *dados, int bloco, int nblocos) {
	LOG(LOG_DEBUG,"Ler bloco %i a %i", bloco, bloco + nblocos - 1)
	if(ficheiro == NULL || bloco < 0 || bloco >= size || nblocos < 1) return 0;
	
    //QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
    if((int)fseek(ficheiro, bloco * blockSize, SEEK_SET) != 0) {mutex->unlock();return 0; } // erro!
    nblocos = bloco + nblocos > size ? size - bloco : nblocos;
    int iaux = (int)fread(dados , blockSize, nblocos, ficheiro);// SIL
    mutex->unlock();// SIL 
    return iaux;
}

bool TmpFile::writeStruct(void *dados, int bloco, int nblocos) {
	if(ficheiro == NULL || bloco < 0 || nblocos < 1) return 0;
    
	//QMutexLocker locker(mutex);// SIL 
	mutex->lock();// SIL 
    if(bloco > size) if(!setStructSizeInternal(bloco)) {mutex->unlock();return false;}
    if((int)fseek(ficheiro, bloco * blockSize, SEEK_SET) != 0){
        LOG(LOG_ERROR,"falhou movimento do cursor para o bloco %i",bloco)
        mutex->unlock();
        return false;
        }
    if((int)fwrite(dados, blockSize, nblocos, ficheiro) != nblocos) {
        LOG(LOG_ERROR,"falhou escrita: bloco = %i a %i",bloco,bloco+nblocos-1)
        mutex->unlock();
        return false;
        }
    if(bloco+nblocos > size) size = bloco+nblocos;
    mutex->unlock();// SIL
    return true;
}

bool TmpFile::setStructSize(int nsize) {
	if(ficheiro == NULL || nsize < 0 ) return false;

	//QMutexLocker locker(mutex);// SIL
    mutex->lock();// SIL
    bool baux = setStructSizeInternal(nsize);// SIL
    mutex->unlock();// SIL
    return baux;
}

inline bool TmpFile::setStructSizeInternal(int nsize) {
	if(structDefault == NULL) return false;
	if(nsize <= size) {
		size = nsize;
	} else {
		while(nsize > size) {	// SetSize "personalizado"
			LOG(LOG_WARN,"A escrever um bloco não contínuo, na estrutura de blocos")
			if((int)fseek(ficheiro, size * blockSize, SEEK_SET) != 0){
				LOG(LOG_ERROR,"falhou movimento do cursor para o fim")
				return false;
			}
			if((int)fwrite(structDefault, blockSize, 1, ficheiro) != 1){
				LOG(LOG_ERROR,"falhou escrita de um bloco no fim")
				return false;
			}
			size++;
		}
	}
	return true;
}